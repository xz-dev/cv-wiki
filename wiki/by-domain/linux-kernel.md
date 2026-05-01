# Linux/BSD 内核与系统底层

> 跨操作系统内核开发，从 Linux 调度器优化到 FreeBSD VirtIO 驱动，涵盖 Linux 桌面基础设施调试

---

## 📊 技术领域概览

- **涵盖项目**: freebsd-src, flatpak, CachyOS/kernel-patches, python-evdev, Linux 内核主线, kernel-autofdo-container
- **主要贡献**: FreeBSD virtio_balloon 驱动实现, Linux 桌面 CVE 回归修复, 调度器补丁, cgroup 机制, 内核性能优化, 输入子系统分析
- **技术栈**: C, Shell, AutoFDO, Linux Kernel, FreeBSD Kernel, VirtIO, cgroup v2, evdev
- **贡献类型**: 内核驱动实现, 安全回归修复, 内核补丁, 性能优化, 系统工具
- **认证资质**: RHCE (Red Hat Certified Engineer), RHCSA

---

## 1. 内核调度器优化

### CachyOS 内核补丁维护

CachyOS 是一个优化的 Arch Linux 发行版，提供各种性能改进的内核补丁，如 Project C (prjc) 调度器和 BMQ/PDS 调度器。

#### PR #135: 修复 6.12.65+ 版本的 prjc 补丁

**问题背景**:
- Linux 6.12.65+ 版本中，prjc 调度器补丁应用失败
- 根本原因: 缺少 `<linux/prandom.h>` 头文件引用，导致编译错误

**解决方案**:
```diff
--- a/linux612-cachydisabled/0001-sched-core-skip-the-broken-task-in-resched_curr.patch
+++ b/linux612-cachydisabled/0001-sched-core-skip-the-broken-task-in-resched_curr.patch
@@ -10,6 +10,7 @@ index 8cb7e2bbc..b24cb7eee 100644
 #include <linux/init_task.h>
 #include <linux/kallsyms.h>
 #include <linux/futex.h>
+#include <linux/prandom.h>
 #include <linux/compat.h>
 #include <linux/uaccess.h>
 #include <linux/nmi.h>
```

**技术亮点**:
- 快速定位核心修复点，避免整个补丁的重写
- 为社区维护关键性能补丁
- 解决了大量下游用户的内核编译失败问题

#### PR #132: 解决 cpufreq_schedutil 兼容性问题

**问题描述**:
- 调度器补丁与 CPU 频率调节器 (schedutil) 的冲突
- 在负载计算和任务迁移时出现的竞态条件

**解决方案**:
- 重写 schedutil 接口的部分调用顺序
- 添加同步点确保负载计算与频率调整的一致性

**影响范围**:
- 提升桌面响应性能
- 解决功耗与性能平衡问题
- 减少系统微冻结

## 2. 系统容器和 cgroup 研究

### distrobox PR #1982 深入分析

在改进 distrobox 项目过程中，深入研究了 Linux cgroup v2 的委托机制和 PID 命名空间的互动关系，这展现了极强的内核机制理解能力。

**cgroup v2 委托链分析**:

```
systemd系统:
/sys/fs/cgroup/user.slice/user-1000.slice/...
├── cgroup.procs          (systemd管理)
└── delegate/             (用户有写权限)
    └── podman-xxx/
        └── container/

非systemd系统 (OpenRC/elogind):
/sys/fs/cgroup/
├── cgroup.procs          (root拥有)
└── user.slice/           (❌ 无delegate子树)
    └── podman-xxx/       (用户无法清理cgroup)
```

**PID命名空间与cgroup交互**:
当容器使用 `--pid host` 运行时，进程在主机PID命名空间，但cgroup仍需管理这些进程。不同初始化系统的cgroup委托机制差异导致清理问题。

**主要解决方案**:
- 检测cgroup路径为空的情况
- 使用多层次回退策略：SIGTERM → SIGKILL → 强制删除
- 保持与systemd和非systemd系统的兼容性

## 3. 内核性能优化工具

### kernel-autofdo-container

个人开发的内核性能优化工具，用于生成更高性能的内核编译配置。

**主要功能**:
- 在容器内通过 phoronix-test-suite 生成性能分析数据
- 使用 AutoFDO 技术转换为编译器优化指令
- 生成可供内核编译使用的配置文件

**核心技术**:
```python
def generate_gcov_from_profile(profile_path):
    """将perf profile转换为GCOV格式"""
    cmd = [
        "create_gcov", 
        "--binary=/proc/kcore", 
        f"--profile={profile_path}",
        "--gcov=kernel.gcov"
    ]
    subprocess.run(cmd, check=True)
    return "kernel.gcov"

def apply_to_kernel_config(gcov_file, config_path):
    """应用GCOV数据到内核配置"""
    with open(config_path, "r") as f:
        config = f.readlines()
    
    # 添加AutoFDO相关配置
    config.append("CONFIG_AUTOFDO=y\n")
    config.append(f"CONFIG_GCOV_PROFILE_AUTO={gcov_file}\n")
    
    with open(config_path, "w") as f:
        f.writelines(config)
```

**性能提升**: 
- 测试显示优化后的内核在特定场景下性能提升5-15%
- 减少I/O密集型工作负载的延迟波动
- 提高系统整体响应性

## 4. Linux系统管理技术实践

### OpenRC 服务与初始化系统

为多个项目贡献了OpenRC服务脚本，展示了对Linux初始化系统的深入理解：

- 为 Gentoo 的 KDE Plasma KRDP 添加 OpenRC 服务
- 为 clash-verge-bin 添加和优化 OpenRC 服务
- 为 EmixamPP/linux-enable-ir-emitter 添加 OpenRC 支持

**OpenRC 服务开发技巧**:
- 正确处理依赖关系
- 遵循最小权限原则
- 确保优雅退出
- 提供日志和调试支持

## 5. FreeBSD 内核 - VirtIO Balloon 驱动

### freebsd/freebsd-src PR #2116 (⭐9,000)

**首次 FreeBSD 内核贡献** (2026-04-03 起，2026-04-13 仍在持续迭代)

为 FreeBSD 的 virtio_balloon 驱动实现自 FreeBSD 9.0 以来缺失的两个 VirtIO 特性:

**VIRTIO_BALLOON_F_STATS_VQ**:
- 通过 stats virtqueue 向 Hypervisor 报告 6 种客户机内存统计
- 使用 FreeBSD 特有的 `vm_page_t`、`vm_cnt` 等 API 获取内存信息
- 统计项: free, total, available, swap_in/out, major_faults, disk_caches

**VIRTIO_BALLOON_F_DEFLATE_ON_OOM**:
- 在客户机内存压力时自动放气 balloon
- 将页面归还 VM 内存子系统，避免进程被 OOM killer 杀死
- 在 balloon 已占用可回收页面的情况下提供安全网

**改动**: 当前分支累计 +367/-25 行, 2 个文件  
**对齐**: 头文件定义与 OASIS virtio-v1.2 规范严格对齐

**后续打磨**:
- 修复 OOM deflation 后立即被 balloon 线程重新充气的问题
- 将 `S_AVAIL` 调整为更贴近 virtio 规范语义的 available memory 统计
- 在同步操作后重新启用 queue interrupts，避免后续通知链被静默卡住
- 2026-04-10 将 patch 思路发到 FreeBSD virtualization 邮件列表继续征求反馈

**跨 OS VirtIO 专长**:

| 操作系统 | 驱动 | 贡献内容 |
|---------|------|---------|
| **Windows** | VirtIO GPU (viogpu) | BSOD 修复、8K/HDR 支持、多块连续内存分配、间接描述符 |
| **FreeBSD** | VirtIO Balloon | 内存统计报告、OOM 自动放气 |

同一个 VirtIO 规范，在两个完全不同的内核中实现，展示对虚拟化 I/O 标准的深入理解和跨 OS 内核编程能力。

---

## 6. Linux 桌面基础设施 - flatpak 安全回归修复

### flatpak/flatpak PR #6567 (⭐4,868)

**诊断并修复 CVE-2026-34078 安全修复引入的回归** (2026-04-08)

**问题**: Flatpak 1.16.4 中 Steam 无法启动。`steam-runtime-check-requirements` 使用 `--app-path=""` 测试子沙箱机制，但该代码路径被 CVE 修复破坏。

**根因定位** (`common/flatpak-run.c`):

1. `flatpak_run_app()` 中 runtime fd 选择分支检查了错误的变量名 (`custom_app_fd` 而非 `custom_runtime_fd`)
2. `flatpak_run_add_extension_args()` 在空 app 路径时收到 NULL 指针

**诊断过程**: Steam 报版本错误 → `steam-runtime-check-requirements` → flatpak 子沙箱 spawn → C 源码 CVE 修复 commit `ac62ebe3` → 变量名 typo 和缺失的 NULL guard

修复被 flatpak 核心维护者 @smcv 采纳并整合到官方 PR #6569 中 (第一个 commit 标注 `From: @xz-dev`)。

---

## 7. Linux 输入子系统分析

### python-evdev PR #251 (⭐376) + numlockw 调查

**深入 Linux 内核 input 子系统源码** (2026-04-01)

在调查 numlockw 触控板 LED 脉冲问题时，对 Linux input 子系统进行了详细的源码分析:

```
drivers/input/evdev.c:   evdev_open() — 不区分 O_RDWR/O_RDONLY
drivers/input/input.c:   input_open_device() → dev->open(dev)
drivers/hid/hid-input.c: hidinput_open() → hid_hw_open()
→ USB/I2C 传输层重初始化 → EC 固件 LED 重 assert
```

**核心发现**: LED 脉冲不是打开模式 (读/写) 的问题，而是重复 open/close 循环导致硬件驱动重初始化。正确的修复是保持 fd 长期打开 (evdev-holder 守护进程)。

基于此分析，向上游 python-evdev 提交了 `readonly` 参数改进 (PR #251)，并在 numlockw 中实现了 evdev-holder 守护进程作为根本解决方案。

---

## 8. Linux 显示驱动调试 - amdgpu MST DSC AUX 路由

### 本地调试补丁: MST DSC aux routing refresh workaround

**Gist**: <https://gist.github.com/xz-dev/b0b7983ad244c890ffebe10f3ef00d66>  
**最后活跃**: 2026-04-13

这是一个尚未正式提交上游的本地调试 patch，用于定位 amdgpu 在 MST Hub 环境下的 suspend/resume 黑屏问题。

**问题场景**:
- DCN 3.5 + Synaptics MST Hub
- s2idle resume 后，一个下游显示器随机黑屏，另一个正常恢复
- 失败 sink 不固定，更像 MST 拓扑或 DSC AUX 路由状态陈旧，而不是单个面板 quirk

**核心分析**:

gist 评论中的问题分析给出了关键判断: `aconnector->dsc_aux` 在 MST probe 时计算并缓存，但 suspend/resume 与 MST topology rebuild 后，connector 生命周期长于 `mst_output_port` 路由状态，导致恢复后 sink-side DSC 编程可能仍在使用过期 AUX 路径。

**补丁方向**:
1. 新增 `amdgpu_dm_mst_refresh_dsc_aux()`，在 DSC capability 验证和 sink-side DSC enable/disable 前重新根据当前 `mst_output_port` 刷新 `dsc_aux`
2. 将 DSC DPCD write 的返回值从 `bool` 改为 `int`，保留有符号错误码
3. 在 MST sink-side DSC enable 失败时提前终止 stream bring-up，而不是继续把错误吞掉

**为什么这条分析有价值**:
- 不是简单地“加个 workaround 就好”，而是先通过复现行为判断问题更像 stale routing/state
- 明确区分“refresh AUX 路由本身”与“让失败保持可见、不被静默吞掉”这两个因素
- 将显示恢复失败拆解到 MST topology rebuild、connector 生命周期和 DSC sink-side programming 之间的交互

**测试环境**:
- ASUS Vivobook S 16 M5606WA
- AMD Ryzen AI 9 365 / Radeon 890M
- `6.19.12-cachyos`
- Wayland / KWin
- MST outputs: `DP-8 1920x1200@59.95`, `DP-9 3840x2160@60.00`

---

## 9. 后量子密码学交叉架构编译修复

### leancrypto: ARMv8 后端 x86_64 LTO 构建修复

**PR**: [smuellerDD/leancrypto#58](https://github.com/smuellerDD/leancrypto/pull/58) ✅ 已合并 (2026-04-14)

**问题**: Gentoo x86_64 启用 LTO 编译 leancrypto 失败，SPHINCS+ ARMv8 后端函数指针表在非 AArch64 目标产生未定义引用

**诊断链**:
1. 链接器报 undefined reference 到 `lc_sphincs_shake_192s_sphincs_merkle_sign_armv8` 等符号
2. 追溯源码发现 `slh-dsa/src/sphincs_sign.c` 中 `f_ctx_armv8` 静态函数表无条件定义
3. 虽然运行时仅在 `LC_HOST_AARCH64` 宏下选择 ARMv8 路径，但编译期 LTO 保留了这些符号导致链接失败

**修复**: 用 `LC_HOST_AARCH64` 条件编译守卫 ARMv8 后端 includes 和函数指针表，使编译时可见性与运行时分派条件一致

**技术亮点**: 从 x86_64 链接错误反推 ARMv8 条件编译缺失，体现对不同架构编译模型 (LTO 符号可见性) 的深入理解

---

## 🎯 总结与技能展示

### 核心技能
- **跨 OS 内核开发**: Linux + FreeBSD 内核编程，同一 VirtIO 规范在不同内核中的实现
- **安全回归诊断**: 从用户层面追溯到 CVE 修复引入的 C 代码 bug
- **内核源码分析**: 深入 evdev/input/hid 驱动栈定位硬件交互问题
- **显示驱动长尾调试**: MST topology、AUX routing、DSC sink-side programming 的跨层交互定位
- **交叉架构编译诊断**: 从链接错误反推条件编译宏缺失 (LTO 符号可见性、ARMv8 vs x86_64)
- 掌握容器技术底层实现 (命名空间、cgroup)
- 熟悉不同初始化系统 (systemd、OpenRC) 的工作机制

### 认证与职业发展
- 通过RHCE认证，展示企业级Linux管理能力
- RHCSA认证，掌握系统管理基础
- 持续关注内核社区发展，跟踪最新功能和变化

---

**文件版本**: v2.2  
**最后更新**: 2026-05-01
