# Open Source Contribution Wiki

一套系统化的开源贡献档案系统，记录 9 年的 GitHub 贡献历程，并附带可复用的分析方法论。

---

## 这是什么？

这个仓库包含两个核心部分：

1. **个人开源贡献 Wiki** (`wiki/`) - 记录 2017-2026 年间 200+ 个 Pull Requests 的详细技术分析
2. **分析方法论** - 一套可复用的开源贡献分析框架，适用于任何 GitHub 用户

## 为什么做这个？

开源贡献不仅仅是提交代码。每一个 PR 背后都有：

- 问题发现和根因分析
- 技术方案设计和权衡
- 与维护者的沟通协作
- 对上下游的影响评估

这些信息散落在各个 GitHub 仓库中，难以系统化展示。这个项目旨在：

1. **结构化存档** - 按年份/规模/领域多维度组织
2. **深度分析** - 不只是 PR 列表，而是技术细节剖析
3. **AI 友好** - 专门的分析指南，便于 AI 助手理解和检索
4. **可复用** - 方法论可以应用于任何开发者

---

## 快速开始

### 浏览 Wiki

```bash
# 查看主索引
cat wiki/README.md

# 按项目规模浏览（推荐开始）
cat wiki/by-scale/mega-projects.md      # 超大项目 (>30k stars)
cat wiki/by-scale/large-projects.md     # 大项目 (10k-30k stars)

# 按技术领域浏览
cat wiki/by-domain/container-tech.md    # 容器技术
cat wiki/by-domain/linux-kernel.md      # Linux 内核

# 深度分析
cat wiki/deep-dive/mcp-servers.md       # MCP 协议贡献
cat wiki/deep-dive/github-issues-analysis.md  # Issues 互动分析
```

### 搜索特定内容

```bash
# 搜索关键词
grep -r "并发" wiki/
grep -r "MCP" wiki/
grep -r "distrobox" wiki/

# 查找特定项目
grep -r "modelcontextprotocol/servers" wiki/
```

---

## 目录结构

```
.
├── README.md                  # 本文件
├── WIKI_SUMMARY.md           # Wiki 构建报告
│
└── wiki/                      # 核心内容
    ├── README.md              # Wiki 主索引
    ├── HOW_TO_ANALYZE.md      # AI 分析指南 (核心方法论)
    ├── CONTRIBUTING.md        # 维护指南
    ├── MEMORY_CLEANUP.md      # 记忆管理策略
    ├── CROSS_REFERENCES.md    # 交叉引用表
    │
    ├── by-year/               # 按年份 (2018-2026)
    ├── by-scale/              # 按项目规模
    │   ├── mega-projects.md   # >30k stars
    │   ├── large-projects.md  # 10k-30k stars
    │   ├── medium-projects.md # 1k-10k stars
    │   └── small-projects.md  # <1k stars
    │
    ├── by-domain/             # 按技术领域
    │   ├── linux-kernel.md
    │   ├── windows-drivers.md
    │   ├── container-tech.md
    │   ├── ai-infrastructure.md
    │   ├── android.md
    │   └── gentoo-ecosystem.md
    │
    ├── deep-dive/             # 深度分析
    │   ├── mcp-servers.md
    │   ├── virtio-gpu-driver.md
    │   ├── distrobox-contributions.md
    │   ├── upgradeall-project.md
    │   ├── github-issues-analysis.md
    │   └── websites/          # 网站与社区分析
    │       ├── README.md
    │       ├── blog-20XX.md   # 博客文章按年份
    │       ├── stack-exchange.md
    │       ├── mastodon.md
    │       └── linux-wiki-contributions.md
    │
    └── personal-projects/     # 个人项目
        ├── distrobox-plus.md
        ├── numlockw.md
        └── ...
```

---

## 分析方法论

这套方法论可用于分析任何 GitHub 用户的开源贡献。

### 核心步骤

#### 1. 数据收集

```bash
# 使用 GitHub CLI 批量获取 PR
gh search prs --author=USERNAME --state=all --limit=200 \
  --json repository,title,number,state,createdAt,mergedAt,url

# 获取项目元数据（Stars/Forks）
gh api repos/OWNER/REPO --jq '.stargazers_count'
```

#### 2. 分类整理

按三个维度组织：

| 维度 | 分类标准 | 说明 |
|------|----------|------|
| **规模** | 项目 Stars | mega(>30k), large(10k-30k), medium(1k-10k), small(<1k) |
| **领域** | 技术栈 | 内核、容器、AI基础设施、Android 等 |
| **时间** | 创建日期 | 按年份组织，展示成长路径 |

#### 3. 深度分析（重点 PR）

对于高影响力的 PR，记录：

- **问题描述**: 场景、根因、影响范围
- **解决方案**: 技术架构、关键代码、设计权衡
- **技术亮点**: 创新点、优化策略
- **影响评估**: 解决了什么痛点、影响用户规模

#### 4. Issues 互动分析

PR 之外，Issues 回复同样重要：

- **纯语言解决能力**: 无需代码就能指导用户解决问题
- **问题诊断能力**: 快速定位根因
- **技术沟通质量**: 清晰、有逻辑、提供完整方案

#### 5. 博客/社区分析 (v2.1+)

技术博客和社区贡献展示深度：

- **技术深度**: 原理解析、源码分析
- **知识分享**: 踩坑记录、最佳实践
- **写作质量**: 结构清晰、逻辑连贯

#### 6. 技术论坛分析 (v2.2+)

Stack Overflow、知乎等平台：

- **点进具体回答查看**（不只是看统计数据）
- **分析回答质量**: 代码示例、原理解释、替代方案
- **识别专业领域**: 从标签统计找到擅长方向

### 工具选择

| 用途 | 推荐工具 | 避免 |
|------|----------|------|
| 批量获取 PR | `gh` CLI | GitHub Web UI |
| 项目元数据 | Firecrawl / `gh api` | Playwright 浏览器 |
| 代码分析 | `git clone` + 直接读取 | 浏览器查看 (DOM 过大) |
| 结构化存储 | MCP Memory Service | 重复存储相似内容 |
| 博客抓取 | Firecrawl | - |

### 避免的陷阱

- 用浏览器查看代码（DOM 包含大量无关元素）
- 只关注 PR 忽略 Issue 互动（遗漏沟通能力展示）
- 看到论坛链接不点进去（遗漏实战问题解决能力）
- 只看统计数据不看具体回答内容（遗漏技术深度）

详细方法论请参阅: [`wiki/HOW_TO_ANALYZE.md`](wiki/HOW_TO_ANALYZE.md)

---

## 统计概览

| 指标 | 数值 |
|------|------|
| 总 PR 数量 | 200+ |
| 贡献项目数 | 100+ |
| 总 Stars | 120,000+ |
| 活跃年限 | 9 年 (2017-2026) |
| 合并率 | 85% |

### 项目规模分布

```
超大项目 (>30k stars):   2 个  - modelcontextprotocol/servers, LibreChat
大项目 (10k-30k stars):  1 个  - distrobox
中等项目 (1k-10k stars): 6 个  - virtio-win, gentoo, ansible-runner 等
小项目 (<1k stars):    191 个  - Gentoo 生态、Android 应用等
```

### 技术领域分布

```
Linux 系统     ████████████████████ 40%
AI 基础设施    █████████████░░░░░░░ 25%
容器技术       ████████░░░░░░░░░░░░ 15%
Android       █████░░░░░░░░░░░░░░░ 10%
Windows 驱动   ███░░░░░░░░░░░░░░░░░  5%
其他          ███░░░░░░░░░░░░░░░░░  5%
```

---

## 亮点贡献

### MCP Servers - 跨进程文件锁 (77k+ stars)

**问题**: MCP 多实例并发写入 memory.json 导致数据损坏

**方案**: 使用 `proper-lockfile` 实现跨进程互斥，支持 stale lock 检测

**影响**: 解决所有 MCP 用户的数据安全问题

[详细分析](wiki/deep-dive/mcp-servers.md)

### distrobox - cgroup 委托问题 (18k+ stars)

**问题**: systemd 容器内 cgroup 权限不足导致服务启动失败

**方案**: 配置 cgroup 委托 (`--cgroupns=host` + systemd slice)

**影响**: 修复 Fedora/Ubuntu 用户在 distrobox 中运行 systemd 服务的问题

[详细分析](wiki/deep-dive/distrobox-contributions.md)

### VirtIO GPU Driver - 8K 分辨率支持 (2.5k+ stars)

**问题**: 高分辨率模式导致 Windows 虚拟机 BSOD

**方案**: 修复 EDID 解析和帧缓冲分配逻辑

**影响**: 支持 8K/HDR 等高端显示需求

[详细分析](wiki/deep-dive/virtio-gpu-driver.md)

### Linux Wiki 贡献 (Arch + Gentoo)

- **Arch Wiki**: 29 次编辑 (ZFS, QEMU, Nix 翻译)
- **Gentoo Wiki**: 35 次编辑 (Hyprland, Steam OpenRC, ZFS)

**亮点**: 跨发行版维护 ZFS 文档，填补 Hyprland xdg-desktop-portal 空白

[详细分析](wiki/deep-dive/websites/linux-wiki-contributions.md)

---

## 相关链接

### 代码平台

- [GitHub](https://github.com/xz-dev)
- [GitLab](https://gitlab.com/xz-dev)
- [Codeberg](https://codeberg.org/xz-dev)

### 技术博客与简历

- [技术博客](https://xzos.net/) - 55+ 篇技术文章 (2017年至今)
- [简历](https://xzos.net/cv/xiangzhe_cv-zh_en.pdf)

### Linux Wiki 贡献

- [Arch Wiki](https://wiki.archlinux.org/title/Special:Contributions/Xz-dev)
- [Gentoo Wiki](https://wiki.gentoo.org/wiki/Special:Contributions/Inkflaw)

### Stack Exchange (用户名: inkflaw)

- [Stack Overflow](https://stackoverflow.com/users/15715806/inkflaw)
- [Ask Ubuntu](https://askubuntu.com/users/2416571/inkflaw)
- [Unix & Linux](https://unix.stackexchange.com/users/492540/inkflaw)

### 社交媒体

- [Mastodon](https://fosstodon.org/@xzdev)
- [Ko-fi](https://ko-fi.com/xz117514)

---

## 许可证

本项目内容采用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 许可。

分析方法论可自由复用，欢迎用于分析其他开发者的开源贡献。

---

## 贡献

欢迎提交 Issue 或 PR：

- 修正错误信息
- 改进分析方法论
- 补充新的分析维度

---

**最后更新**: 2026-02-04  
**方法论版本**: v2.2 (增强技术论坛深度分析)
