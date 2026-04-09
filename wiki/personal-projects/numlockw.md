# numlockw - NumLock 控制工具

> **定位**: Wayland/TTY 环境下的 NumLock 状态控制工具 (numlockx 的 Wayland 替代)  
> **状态**: 已发布 v0.1.6  
> **技术栈**: Python, evdev, uinput  
> **仓库**: [xz-dev/numlockw](https://github.com/xz-dev/numlockw) (13 Stars)

---

## 项目概览

| 属性 | 值 |
|------|-----|
| **语言** | Python |
| **创建时间** | 2024-07-21 |
| **安装方式** | `pipx install numlockw` |
| **目标环境** | Wayland, TTY, 无 X11 依赖 |
| **关键词** | evdev, keyboard, uinput, wayland, tty |

---

## 核心功能

- **NumLock 状态控制**: on / off / toggle / status
- **设备列表**: list-devices 枚举所有输入设备
- **多设备支持**: `--device-name` 指定设备或 `*` 操作所有设备
- **uinput 模拟**: 默认通过创建虚拟键盘发送 NumLock 按键事件
- **LED 强制模式**: `--force-led` 直接设置 LED_NUML，不依赖系统响应
- **等待设备**: `--wait-dev` 等待指定设备就绪 (适用于 init 脚本)
- **Pre-hook**: `--pre-hook` 在 NumLock 切换时执行自定义命令

---

## 2026-04 重大更新: LED 脉冲修复

### 问题背景

用户在 [Reddit](https://www.reddit.com/r/tuxedocomputers/comments/1rtj3c9/) 报告: 在 Tuxedo Stellaris 15 Gen3 上，numlockw 以 1-2Hz 轮询 `InputDevice.leds()` 时触控板 LED 持续脉冲。

### 根因分析 (深入内核源码)

深入调查 Linux 内核源码 (`drivers/input/evdev.c`, `drivers/input/input.c`) 后发现:

1. **不是 `O_RDWR` vs `O_RDONLY` 的问题**: 内核 `evdev_open()` 不区分打开模式，两者走完全相同的路径
2. **真正根因是重复的 open/close 循环**: 每次关闭 fd 时 `dev->users` 降为 0；下次打开触发硬件驱动的 `open()` 回调:
   ```
   evdev_open() → input_open_device() → dev->open(dev)
   → hidinput_open() → hid_hw_open() → USB/I2C 传输层重初始化
   ```
3. 在特定硬件 (Tuxedo Stellaris 15 Gen3) 上，EC 固件在每次传输层重初始化时重新 assert LED 状态，导致可见的脉冲

### 解决方案

**1. evdev-holder 守护进程** (`workarounds/evdev-holder/`):
- systemd service 形式运行
- 保持设备 fd 持续打开，避免 `dev->users` 降为 0
- 通过检查 `/dev/input/eventX` 路径存在性检测设备拔出
- 这是根本解决方案: `EVIOCGLED` ioctl 是纯内核内存读取 (`bitmap_copy`)，不触及硬件

**2. status 命令只读打开**:
- `status` 命令改为只读方式打开设备
- 避免不必要的 `O_RDWR` 尝试 (虽然根因不在此，但语义更正确)

**3. 推动上游改进**:
- 向 [python-evdev](https://github.com/gvalkov/python-evdev) 提交 [PR #251](https://github.com/gvalkov/python-evdev/pull/251)
- 添加 `readonly=True` 参数，让调用方表达 "只需读权限" 的语义
- 添加 `writable` 参数到 `list_devices()`/`is_device()` 用于枚举可读但不可写的设备

### 技术意义

这次调查展示了从用户层问题追溯到内核驱动回调的完整分析链:
```
用户报告 LED 脉冲
  → numlockw 代码审查
    → python-evdev O_RDWR/O_RDONLY 差异分析
      → Linux evdev.c 源码: evdev_open() 不区分模式
        → input.c: input_open_device() → dev->open() 回调
          → hid-input.c: hidinput_open() → hid_hw_open()
            → USB/I2C 传输层重初始化 → EC 固件 LED 重 assert
```

---

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| 0.1.6 | 2026-01-20 | 添加 `--wait-dev` 等待设备就绪 |
| 0.1.5 | 2026-01-20 | 修复设备检测逻辑 |
| 0.1.4 | 2026-01-17 | 改进设备枚举 |
| - | 2026-04-01 | 添加 evdev-holder 守护进程, status 只读模式 |

---

## 关联项目

- [python-evdev PR #251](https://github.com/gvalkov/python-evdev/pull/251) — 受 LED 脉冲调查直接驱动的上游改进
- [hid-rgb-ctl](./hid-rgb-ctl.md) — 同属 Linux HID/输入子系统领域
- **技能展示**: Linux 输入子系统 (`evdev`, `uinput`, `hidraw`), 内核源码分析, 硬件交互

---

**文件版本**: v1.0  
**最后更新**: 2026-04-09
