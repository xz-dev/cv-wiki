# 小项目贡献 (<1k ⭐)

> 广泛参与开源生态维护，涵盖发行版支持、Android 客户端优化及 AI 基础设施开发。

---

## 📊 统计概览

- **PR 总数**: 204
- **时间跨度**: 2018 - 2026 (9年)
- **主要领域**:
  - **Gentoo 生态**: 128 个 microcai/gentoo-zh PR + gentoo/guru/gentoo 官方仓库维护
  - **Klavis AI / MCP 基础设施**: 36 个 Klavis PR + MCP 相关个人工具
  - **Android 应用**: ~20 个 PR
  - **系统/网络/内核/桌面工具**: ~30+ 个 PR
  - **AI agent 工具链补丁**: pi-guardrails, plannotator, reframe 等 2026 新增小/中型项目

---

## 1. Gentoo 生态维护 (⭐ 多样)

长期致力于 Gentoo Linux 社区的包维护工作，涉及官方仓库及多个 Overlay。

### 代表性贡献
- **microcai/gentoo-zh**: 
  - 维护 `opencode-bin` (1.1.48 → 1.16.2, 含 9999 live ebuild)。
  - 维护 `anytype-bin` (0.53.1 → 0.55.5)，并补充 `lceda-pro` 等二进制包细节修复。
  - PR #9269~10415: 持续快速迭代版本（2026 年 2-6 月持续维护）。
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
  - PR #14: ✅ 已合并 - 迁移到 AGP 9.0 新 DSL API (2026-02-16)
  - 修复 ABI 交叉编译匹配逻辑并兼容 Gradle 9。
- **Szowisz/CachyOS-kernels** (活跃维护):
  - 添加 6.18.10/6.18.12/6.19.2 内核版本，更新 PRJC 补丁
  - 修复 musl/LLVM profiles 下不依赖 GCC 的支持
- **vaeth/zram-init** (⭐87):
  - PR #57 (2026-02-25): 修复 OpenRC 服务依赖导致 KDE Plasma Wayland 启动死锁。zram 挂载 `/tmp` 晚于 `bootmisc`，覆盖了 `/tmp/.X11-unix`，导致 Xwayland socket 创建失败 → `DISPLAY` 未设置 → `ksmserver` 崩溃 → `plasmashell` 死锁。根因是 init 脚本服务依赖方向错误。

**技术栈**: C, Rust, Gradle, Shell, OpenRC, Linux Kernel, CI (GitHub Actions)

---

### 5. smuellerDD/leancrypto — 交叉架构编译修复

**项目简介**: 轻量级后量子密码学库  
**技术栈**: C, LTO, ARMv8/AArch64 条件编译  
**GitHub**: https://github.com/smuellerDD/leancrypto

**PR #58 — SLH-DSA: guard ARMv8 backend on non-AArch64 builds (2026-04-14)**

**状态**: ✅ 已合并  
**改动**: +4 行, 1 个文件

**问题**: Gentoo x86_64 启用 LTO 编译失败，SPHINCS+ ARMv8 后端的函数指针表 (`f_ctx_armv8`) 在非 AArch64 目标上产生未定义符号引用

**诊断链**: 链接器 undefined reference 错误 → 追溯到 ARMv8 后端表无条件定义 → 虽运行时仅在 `LC_HOST_AARCH64` 下选择 ARMv8 路径，但编译期 LTO 保留了这些符号

**修复**: 用 `LC_HOST_AARCH64` 条件编译守卫 ARMv8 后端 includes 和函数指针表

**体现**: 从 x86_64 链接错误反推 ARMv8 条件编译缺失的跨架构诊断能力

**技术栈**: C, LTO, ARMv8/AArch64 条件编译

---

## 6. gvalkov/python-evdev (⭐376) - Linux 输入子系统

**项目简介**: Linux input 子系统 (evdev) 的 Python 绑定  
**技术栈**: Python, C (ctypes/cffi), Linux evdev  
**GitHub**: https://github.com/gvalkov/python-evdev

### PR #251 - Add readonly parameter to InputDevice and writable parameter to list_devices/is_device

**状态**: 🔄 开放中 (2026-04-01)  
**PR 链接**: https://github.com/gvalkov/python-evdev/pull/251  
**改动**: +33/-7 行, 2 个文件

**动机**

源自 [numlockw](../personal-projects/numlockw.md) 用户报告的触控板 LED 脉冲问题。在深入调查 Linux 内核源码后，向上游 python-evdev 提交 API 改进。

**变更**:
- `InputDevice.__init__()` 新增 `readonly=False` 参数: 跳过不必要的 `O_RDWR` 尝试
- `list_devices()` / `is_device()` 新增 `writable=True` 参数: 允许枚举可读但不可写的设备

**内核分析深度**

PR 描述中包含对 Linux 内核源码的详细分析:

1. `drivers/input/evdev.c` 中 `evdev_open()` 不区分 `O_RDWR` 和 `O_RDONLY`
2. 两种模式均走 `evdev_open()` → `input_open_device()` → `dev->open(dev)` 路径
3. LED 脉冲的真正根因是重复的 open/close 循环: 每次 `dev->users` 降为 0 后重新 open 触发硬件驱动 `open()` 回调 (`hidinput_open()` → `hid_hw_open()` → USB/I2C 传输层重初始化)
4. 在特定硬件 (Tuxedo Stellaris 15 Gen3) 上 EC 固件在重初始化时重新 assert LED 状态

**技术亮点**

- 非破坏性变更: 所有新参数都有向后兼容的默认值
- 现有的 `need_write` 装饰器在 `EventIO.write()` 上已有保护，无需额外防护
- 体现了从用户层问题 → 内核驱动回调的完整诊断链

**关联**: [numlockw](../personal-projects/numlockw.md), [hid-rgb-ctl](../personal-projects/hid-rgb-ctl.md)

---

## 🎯 总结

### 核心价值
1.  **长期的社区贡献者**: 跨越 8 年的持续提交，展现了极高的开源热情。
2.  **全栈系统能力**: 从内核调度器补丁到 Android UI 交互，具备极宽的技术视野。
3.  **MCP 领域先驱**: 深度参与 AI 代理 (Agentic AI) 的基础设施建设。
4.  **内核级问题分析**: 能够深入 Linux 内核源码定位问题根因并推动上游修复。

---

**文件版本**: v1.3  
**最后更新**: 2026-05-01

