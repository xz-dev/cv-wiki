# gentoo-ai-update-repo

> **定位**: AI 驱动的 Gentoo overlay，自动化 ebuild 版本升级  
> **状态**: 活跃使用  
> **技术栈**: Python, opencode CLI, Podman, Gentoo ebuild  
> **仓库**: [xz-dev/gentoo-ai-update-repo](https://github.com/xz-dev/gentoo-ai-update-repo)

---

## 项目概览

| 属性 | 值 |
|------|-----|
| **语言** | Python |
| **创建时间** | 2026-02-08 |
| **AI 调度** | [opencode](https://opencode.ai) CLI |
| **AI 模型** | kimi-k2.5 (版本检查), minimax-m2.1 (ebuild 编写) |
| **测试方式** | Podman 容器 (gentoo/stage3) |

---

## 工作流程

```
python3 update.py app-editors/neovim
```

`update.py` 是轻量编排器，将所有"智能"工作委托给 AI 代理:

1. **复制包** — 从系统仓库 (gentoo, guru 等) 复制到本 overlay
2. **AI 生成版本检查脚本** — `get_latest_version.py`，查询上游 API (GitHub, PyPI, crates.io 等)
3. **检查版本** — 如果上游更新则继续，否则退出
4. **AI 创建新 ebuild** — 复制最新 ebuild、调整内容、生成 Manifest、运行 `pkgcheck scan`
5. **容器测试** — `podman run gentoo/stage3` 挂载 overlay，执行 emerge + AI 生成的冒烟测试

## 使用方式

```bash
# 完整流程 (含容器测试)
python3 update.py app-editors/neovim

# 仅检查是否有更新
python3 update.py app-editors/neovim --dry-run

# 跳过容器测试
python3 update.py app-editors/neovim --skip-test

# 强制重新运行
python3 update.py app-editors/neovim --force

# 指定源仓库
python3 update.py app-editors/neovim::gentoo
```

---

## 技术亮点

- **AI + 传统工具链结合**: AI 负责"理解"和"创造"(解析上游发布、编写 ebuild)，传统工具负责"验证" (pkgcheck, emerge)
- **容器化测试**: 在隔离的 gentoo/stage3 容器中验证 ebuild 可用性
- **多模型协作**: 不同能力的模型负责不同类型的任务
- **实际使用**: 用于维护 opencode-bin 等包的快速版本跟踪

---

## 关联

- [Gentoo 生态维护](../by-domain/gentoo-ecosystem.md) — opencode-bin 30+ 版本的持续更新正是此工具的应用场景
- **技能展示**: AI 工程 (prompt 设计、多模型协作)、Gentoo 包管理 (ebuild、Portage)、容器测试 (Podman)

---

**文件版本**: v1.0  
**最后更新**: 2026-04-09
