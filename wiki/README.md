# xz-dev 开源贡献 Wiki

> **最后更新**: 2026-02-04  
> **数据来源**: GitHub API + 人工整理  
> **贡献时间跨度**: 2017-2026 (9年)

---

## 📊 贡献概览

### 核心数据

| 指标 | 数值 | 说明 |
|------|------|------|
| **总 PR 数量** | 200+ | 包含所有开放和已合并的PR |
| **贡献项目数** | 100+ | 涉及的不同GitHub仓库 |
| **总 Stars** | 120,000+ | 贡献项目的累计Stars |
| **活跃年限** | 9年 | 2017年至今持续贡献 |
| **年均贡献** | 22.2次/年 | 基于metadata.json统计 |
| **合并率** | 85% | 170个已合并, 25个开放中, 5个已关闭 |

### 项目规模分布

```
超大项目 (>30k ⭐):  2个  - modelcontextprotocol/servers, LibreChat
大项目 (10k-30k ⭐):  1个  - distrobox
中等项目 (1k-10k ⭐):  6个  - virtio-win, gentoo, ansible-runner等
小项目 (<1k ⭐):    191个 - Gentoo生态、Android应用等
```

### 技术领域分布

- 🐧 **Linux系统** (40%) - 内核、驱动、Gentoo生态
- 🐳 **容器技术** (15%) - Podman、Docker、distrobox
- 🤖 **AI基础设施** (25%) - MCP协议、工具集成
- 📱 **Android开发** (10%) - 应用、Magisk模块
- 🪟 **Windows驱动** (5%) - VirtIO GPU
- 🛠️ **其他工具** (5%) - 编辑器、网络、自动化

![领域分布图](./visualizations/domain_distribution.png)

---

## 🗂️ Wiki 导航

### 按年份浏览

快速了解技术成长路径和贡献演进：

- [📅 2018年](./by-year/2018.md) - GitHub起步，Android开发
- [📅 2019年](./by-year/2019.md) - UpgradeAll项目创立
- [📅 2020年](./by-year/2020.md) - Android生态深耕
- [📅 2021年](./by-year/2021.md) - 系统工具开发
- [📅 2022年](./by-year/2022.md) - Linux系统探索
- [📅 2023年](./by-year/2023.md) - Gentoo维护者
- [📅 2024年](./by-year/2024.md) - 系统底层探索
- [📅 2025年](./by-year/2025.md) - Klavis AI (MCP基础设施)
- [📅 2026年](./by-year/2026.md) - 内核驱动与容器技术

![贡献时间线](./visualizations/contribution_timeline.png)

### 按项目规模浏览

展示影响力层次：

- [🏆 超大项目 (>30k ⭐)](./by-scale/mega-projects.md) - MCP Servers, LibreChat
- [🔥 大项目 (10k-30k ⭐)](./by-scale/large-projects.md) - distrobox
- [💡 中等项目 (1k-10k ⭐)](./by-scale/medium-projects.md) - virtio-win, gentoo, ansible-runner等
- [📦 小项目 (<1k ⭐)](./by-scale/small-projects.md) - 180+ PRs汇总

![项目规模分布](./visualizations/project_scale_distribution.png)

### 按技术领域浏览

深入技术细节：

- [🐧 Linux内核与驱动](./by-domain/linux-kernel.md) - 内核补丁、调度器、AutoFDO
- [🪟 Windows驱动开发](./by-domain/windows-drivers.md) - VirtIO GPU驱动系列
- [🐳 容器技术](./by-domain/container-tech.md) - distrobox, Podman, cgroup
- [🤖 AI基础设施](./by-domain/ai-infrastructure.md) - MCP协议、Klavis贡献
- [📱 Android生态](./by-domain/android.md) - UpgradeAll, NewPipe, bilimiao2
- [🎯 Gentoo生态](./by-domain/gentoo-ecosystem.md) - 90+ ebuild维护

### 重点项目深度分析

核心贡献的详细技术解析：

- [🔍 MCP Servers - 跨进程文件锁](./deep-dive/mcp-servers.md) - 解决多实例数据损坏问题
- [🔍 VirtIO GPU Driver - 8K分辨率支持](./deep-dive/virtio-gpu-driver.md) - 修复BSOD并支持HDR
- [🔍 distrobox - cgroup委托问题](./deep-dive/distrobox-contributions.md) - PID命名空间隔离
- [🔍 UpgradeAll - Android更新系统](./deep-dive/upgradeall-project.md) - 模块化App更新框架
- [💬 GitHub Issues 互动分析](./deep-dive/github-issues-analysis.md) - 纯语言解决问题能力 **(评分91.3/100)**
- [📝 个人博客分析 (xzos.net)](./deep-dive/blog-analysis.md) - 8年技术写作、Stack Exchange 社区贡献

### 个人项目详解

自主开发的开源工具：

- [📦 distrobox-plus](./personal-projects/distrobox-plus.md) - Python重写distrobox (⭐11)
- [📦 numlockw](./personal-projects/numlockw.md) - NumLock控制工具 (⭐12)
- [📦 AdGuardHome-LogSync](./personal-projects/adguardhome-logsync.md) - 日志同步工具 (⭐4)
- [📦 kernel-autofdo-container](./personal-projects/kernel-autofdo-container.md) - 内核优化工具 (⭐3)

---

## 🔍 快速检索

### 按技术栈查找

| 技术栈 | 相关项目/PR |
|--------|------------|
| **Python** | distrobox-plus, AdGuardHome-LogSync, MCP服务器, UpgradeAll |
| **C/C++** | VirtIO GPU驱动, 内核补丁, DisplayCAL |
| **Kotlin** | UpgradeAll, TestSelf, bilimiao2 |
| **Shell** | Gentoo ebuilds, OpenRC服务, distrobox |
| **TypeScript** | MCP Servers, Klavis项目 |
| **Rust** | hyper-rustls, Wayland工具 |

![语言分布](./visualizations/language_distribution.png)

### 按问题类型查找

| 问题类型 | 代表性PR |
|---------|---------|
| **并发/竞态条件** | [MCP文件锁](./deep-dive/mcp-servers.md), [VirtIO GPU BSOD修复](./deep-dive/virtio-gpu-driver.md) |
| **性能优化** | [内核AutoFDO](./personal-projects/kernel-autofdo-container.md), [distrobox初始化优化](./deep-dive/distrobox-contributions.md) |
| **架构设计** | [MCP进程隔离](./by-year/2025.md#q3-7月-9月), [UpgradeAll模块化](./deep-dive/upgradeall-project.md) |
| **兼容性修复** | [Gradle 9支持](./by-year/2024.md), [GCC 14/15编译修复](./by-domain/gentoo-ecosystem.md) |
| **功能实现** | [NewPipe评论回复](./by-domain/android.md), [bilimiao2倍速播放](./by-domain/android.md) |

### 按系统层级查找

- **内核层** - [Linux内核补丁](./by-domain/linux-kernel.md), [调度器](./by-domain/linux-kernel.md), [Windows驱动](./by-domain/windows-drivers.md)
- **系统层** - [cgroup](./deep-dive/distrobox-contributions.md), [PID namespace](./by-year/2026.md), [文件锁](./deep-dive/mcp-servers.md), [OpenRC](./by-domain/gentoo-ecosystem.md)
- **用户层** - [容器管理](./by-domain/container-tech.md), [MCP服务器](./by-scale/mega-projects.md), [桌面工具](./personal-projects/numlockw.md)
- **应用层** - [Android应用](./by-domain/android.md), [浏览器扩展](./by-year/2025.md), [CLI工具](./personal-projects/adguardhome-logsync.md)

### 交叉引用

查看各项贡献之间的关联和技术能力的延续性：

- [📋 贡献交叉引用表](./CROSS_REFERENCES.md) - 按主题、技术能力和时间线展示关联

---

## 📈 技能矩阵

### 编程语言熟练度

```
Python      ████████████████████ 95% (系统工具, MCP, 自动化)
Shell       ███████████████████░ 90% (Gentoo, 系统管理)
C/C++       ███████████████░░░░░ 75% (内核, Windows驱动)
Kotlin      ████████████████░░░░ 80% (Android应用)
TypeScript  ██████████████░░░░░░ 70% (Node.js, MCP)
Rust        ████████████░░░░░░░░ 60% (系统工具, 学习中)
```

![技能雷达图](./visualizations/skill_radar.png)

### 技术领域深度

```
Linux系统管理  ████████████████████ 100% (RHCE认证)
容器技术      █████████████████░░░  85% (Podman, distrobox贡献者)
并发编程      ████████████████░░░░  80% (跨进程锁, IPC设计)
内核开发      ███████████████░░░░░  75% (调度器优化, CachyOS)
Windows驱动   ████████████░░░░░░░░  60% (VirtIO GPU驱动修复)
Android开发   ███████████████░░░░░  75% (UpgradeAll创始人)
AI基础设施    ██████████████░░░░░░  70% (MCP协议贡献者)
```

---

## 🎯 使用指南

### 如何阅读这个 Wiki

1. **快速浏览**: 从 [按项目规模](./by-scale/) 开始，了解影响力分布
2. **技术深度**: 阅读 [重点项目深度分析](./deep-dive/) 了解核心技术
3. **时间线**: 按 [年份](./by-year/) 浏览，了解技术成长路径
4. **领域专精**: 按 [技术领域](./by-domain/) 深入特定方向
5. **可视化**: 查看 [visualization](./visualizations/) 目录下的图表直观了解

### 给 AI 助手的提示

如果你是 AI 助手，想要分析这个 Wiki：

1. 📖 **必读**: [HOW_TO_ANALYZE.md](./HOW_TO_ANALYZE.md) - 分析方法指南
2. 📊 **数据源**: [metadata.json](./metadata.json) - 结构化数据
3. 🔍 **检索技巧**: 使用 `grep -r "关键词" wiki/` 快速查找
4. 📈 **生成报告**: 基于 metadata.json 可自动生成统计报告

### 数据更新与可视化

- **拉取GitHub数据**: 运行 `./scripts/generate_wiki.sh --update-all`
- **生成可视化图表**: 运行 `./scripts/generate_visualizations.py`
- **按年份更新**: 运行 `./scripts/generate_wiki.sh --update-year 2026`
- **按领域更新**: 运行 `./scripts/generate_wiki.sh --update-domain container-tech`
- **手动修改**: 直接编辑相应的 markdown 文件

---

## 🔗 外部链接

### 代码平台
- **GitHub**: [https://github.com/xz-dev](https://github.com/xz-dev)
- **GitLab**: [https://gitlab.com/xz-dev](https://gitlab.com/xz-dev)
- **Codeberg**: [https://codeberg.org/xz-dev](https://codeberg.org/xz-dev)

### 个人博客与简历
- **技术博客**: [https://xzos.net/](https://xzos.net/) - 55+ 篇技术文章 (2017年至今)
- **简历下载**: [中英双语版](https://xzos.net/cv/xiangzhe_cv-zh_en.pdf) | [English](https://xzos.net/cv/xiangzhe_cv.pdf) | [中文版](https://xzos.net/cv/%E6%9B%BE%E7%A5%A5%E5%93%B2%E7%9A%84%E7%AE%80%E5%8E%86.pdf)

### Stack Exchange 社区 (用户名: inkflaw)
- [Stack Overflow](https://stackoverflow.com/users/15715806/inkflaw) | [Ask Ubuntu](https://askubuntu.com/users/2416571/inkflaw) | [Unix & Linux](https://unix.stackexchange.com/users/492540/inkflaw) | [Emacs](https://emacs.stackexchange.com/users/39834/inkflaw)

### 社交媒体
- **Mastodon**: [https://fosstodon.org/@xzdev](https://fosstodon.org/@xzdev)
- **Donate**: [https://ko-fi.com/xz117514](https://ko-fi.com/xz117514)

---

## 📝 许可证

本 Wiki 内容采用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 许可。

---

**Wiki 版本**: v1.1.0  
**最后更新**: 2026-02-04  
**生成工具**: [generate_wiki.sh](./scripts/generate_wiki.sh) + [generate_visualizations.py](./scripts/generate_visualizations.py)