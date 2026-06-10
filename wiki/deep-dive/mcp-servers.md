# MCP Servers - 跨进程文件锁与多实例数据一致性

> **核心问题**: MCP memory server 在 stdio 多实例场景下并发写入 `memory.json`，进程内锁无法跨进程生效
> **代表 PR**: [modelcontextprotocol/servers #3286](https://github.com/modelcontextprotocol/servers/pull/3286)
> **关联页面**: [超大项目贡献](../by-scale/mega-projects.md#1-modelcontextprotocolservers-77980), [2025 年度贡献](../by-year/2025.md), [2026 年度贡献](../by-year/2026.md)

---

## 1. 背景

MCP 官方 servers 项目是 Model Context Protocol 生态的重要基础设施。memory server 通过本地 JSON 文件保存实体和关系，但在常见客户端模型中，每个客户端会通过 stdio 启动独立 server 进程。

典型场景：

- Claude Desktop、Cline、VSCode 插件同时使用 memory server；
- 每个客户端都有独立 Node.js 进程；
- 所有进程读写同一个 `memory.json`；
- 原先的 `static fileLock` 只在单进程内有效。

---

## 2. 根因分析

### 2.1 进程内锁的边界

原有思路类似：

```typescript
private static fileLock = false;

async write() {
  while (fileLock) await sleep(10);
  fileLock = true;
  await fs.writeFile('memory.json', data);
  fileLock = false;
}
```

这个锁只能保护同一个 Node.js 进程内的并发任务。stdio transport 下的多个 MCP server 是多个 OS 进程，彼此看不到对方的 `fileLock`。

### 2.2 数据损坏路径

```
进程 A read memory.json
进程 B read memory.json
进程 A write memory.json (包含 A 的变更)
进程 B write memory.json (基于旧快照，覆盖 A 的变更)
```

严重时还会出现写入中断导致 JSON 半截文件，进而触发解析失败。

---

## 3. 解决方案

### 3.1 文件系统级锁

使用 `proper-lockfile` 一类的跨进程文件锁，把互斥边界从 JS runtime 提升到文件系统：

```typescript
import lockfile from 'proper-lockfile';

const release = await lockfile.lock(memoryFile, {
  stale: 10000,
  update: 1000,
  retries: {
    retries: 50,
    minTimeout: 100,
    maxTimeout: 1000,
  },
});

try {
  const latest = await readMemory();
  const merged = mergeMemories(latest, incoming);
  await atomicWrite(memoryFile, merged);
} finally {
  await release();
}
```

关键点：

- **stale lock**: 进程崩溃后锁不会永久卡死；
- **retry/backoff**: 多客户端同时写入时排队而非失败；
- **finally release**: 正常和异常路径都释放锁。

### 3.2 读最新 + 合并 + 原子替换

仅加锁还不够，还必须避免用旧快照覆盖新数据：

1. 拿锁后重新读最新文件；
2. 将当前进程变更与最新文件合并；
3. 写入临时文件；
4. `rename()` 原子替换。

```typescript
await fs.writeFile(tmpFile, JSON.stringify(merged, null, 2));
await fs.rename(tmpFile, memoryFile);
```

---

## 4. 技术亮点

| 能力 | 体现 |
|------|------|
| 并发边界识别 | 区分单进程 async 并发和多进程 stdio 并发 |
| 数据一致性 | 读最新、合并、去重、原子替换 |
| 故障恢复 | stale lock、重试、异常释放 |
| 生态影响 | 为其他本地文件型 MCP server 提供范式 |

---

## 5. 影响评估

- 修复多客户端同时使用 memory server 时的数据丢失风险；
- 支持桌面客户端 + IDE 插件 + CLI 同时运行；
- 把「MCP server 本地持久化」从单进程假设升级为多进程安全设计；
- 与 [VirtIO GPU 错误恢复](./virtio-gpu-driver.md) 等案例共同展示跨层排障能力。

---

## 6. 相关贡献链

- 2025: MCP 文件存储、流式传输、IPC 与 memory 插件持续改进；
- 2025-12 / 2026-01: `modelcontextprotocol/servers #3286` 文件锁方案；
- 2026: `modelcontextprotocol/mcp-js #325` IPC 增强；
- LibreChat / Klavis MCP 相关贡献继续复用并发和持久化经验。

---

## 7. 关联阅读

- [超大项目贡献 - MCP Servers](../by-scale/mega-projects.md#1-modelcontextprotocolservers-77980)
- [2025 年度贡献 - MCP 时间线](../by-year/2025.md)
- [AI 基础设施](../by-domain/ai-infrastructure.md)
- [贡献交叉引用表 - MCP 协议与 AI 基础设施](../CROSS_REFERENCES.md#mcp协议与ai基础设施)

---

**文件版本**: v1.0
**最后更新**: 2026-06-10
