# 小项目贡献 (<1k ⭐)

> 广泛参与开源生态维护，涵盖发行版支持、Android 客户端优化及 AI 基础设施开发。

---

## 📊 统计概览

- **PR 总数**: 180+
- **时间跨度**: 2018 - 2026 (8年)
- **主要领域**: 
  - **Gentoo 生态**: ~80个 PR
  - **Klavis AI (工作相关)**: ~50个 PR
  - **Android 应用**: ~20个 PR
  - **系统/网络/内核工具**: ~30个 PR

---

## 1. Gentoo 生态维护 (⭐ 多样)

长期致力于 Gentoo Linux 社区的包维护工作，涉及官方仓库及多个 Overlay。

### 代表性贡献
- **microcai/gentoo-zh**: 
  - 维护 `opencode-bin`。
  - PR #9269/9299: 引入新包并持续迭代版本。
  - 为 `clash-verge-bin` 等网络工具添加 OpenRC 脚本。
- **gentoo/guru**:
  - PR #411: 维护 `quickemu` 虚拟化工具。
  - PR #397: 维护 `auto-cpufreq` 电源管理工具。
  - 修复多项 ebuild 构建依赖（Cython, Zig, Java Runtime 等）。

**技术栈**: Shell, ebuild, OpenRC, Portage, 依赖分析

---

## 2. Klavis AI - MCP 基础设施 (公司项目)

在 Klavis AI 工作期间，深度参与了 Strata MCP 平台的构建，涉及大量集成开发。

### 代表性贡献
- **Strata MCP Servers**:
  - **Playwright MCP**: 实现具备进程隔离能力的自动化操作服务器。
  - **集成开发**: 实现 PayPal, Sentry, S Player, Netlify, Google Calendar, Gmail, QuickBooks, Dropbox 等 20+ 个 MCP 服务器。
- **核心优化**:
  - PR #658: 修复 Google Calendar 的线程安全 HTTP 请求问题。
  - 实现基于 OAuth 的自动化身份验证流程。
  - 维护 Docker 镜像构建流水线 (CI/CD)。

**技术栈**: Python, TypeScript, MCP (Model Context Protocol), Playwright, Docker, OAuth, CI/CD

---

## 3. Android 项目优化 (⭐ 100-500)

针对常用开源 Android 应用进行功能增强和 Bug 修复。

### 代表性贡献
- **10miaomiao/bilimiao2** (B站第三方客户端):
  - PR #160: 自定义倍速菜单排序逻辑。
  - PR #18: 修复解析视频信息导致的崩溃。
  - 移除推荐列表广告及优化交互行为。
- **TeamNewPipe/NewPipe** (YouTube 客户端):
  - PR #9020/9410: 实现评论回复显示功能。
- **topjohnwu/Magisk**: 
  - 维护简体中文翻译及本地化修复。

**技术栈**: Kotlin, Java, Android SDK, UI/UX 优化

---

## 4. 系统、内核与工具 (⭐ 10-300)

### 代表性贡献
- **CachyOS/kernel-patches**:
  - PR #135: 修复 Linux 6.12.65+ 版本的 PrJC 调度器补丁。
  - PR #132: 解决 cpufreq_schedutil 的兼容性问题。
- **heiher/hev-socks5-tunnel**:
  - 为 FreeBSD 添加 TUN 测试及 CI 检查流程。
- **MatrixDev/GradleAndroidRustPlugin**:
  - 修复 ABI 交叉编译匹配逻辑并兼容 Gradle 9。

**技术栈**: C, Rust, Gradle, Linux Kernel, CI (GitHub Actions)

---

## 🎯 总结

### 核心价值
1.  **长期的社区贡献者**: 跨越 8 年的持续提交，展现了极高的开源热情。
2.  **全栈系统能力**: 从内核调度器补丁到 Android UI 交互，具备极宽的技术视野。
3.  **MCP 领域先驱**: 深度参与 AI 代理 (Agentic AI) 的基础设施建设。

---

**文件版本**: v1.0  
**最后更新**: 2026-02-04

