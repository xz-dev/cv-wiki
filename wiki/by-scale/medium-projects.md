# 中等项目贡献 (1k-10k ⭐)

> 关注系统稳定性与跨平台兼容性，在核心组件中修复严重 Bug

---

## 📊 统计概览

- **项目数量**: 5个
- **代表项目**: virtio-win (kvm-guest-drivers + guest-tools-installer), ansible-runner, gentoo, NewPipeExtractor
- **技术领域**: 虚拟化驱动, 自动化工具, Linux发行版, 多媒体提取
- **主要语言**: C, C++, Python, Shell, Java

---

## 1. virtio-win/kvm-guest-drivers-windows (⭐2,550)

**项目简介**: Windows 虚拟化驱动程序（KVM/QEMU）  
**技术栈**: C, C++, Windows 驱动开发 (WDM/WDF), VirtIO  
**GitHub**: https://github.com/virtio-win/kvm-guest-drivers-windows

### 重点贡献：viogpu 驱动稳定性修复

在 2025-2026 年期间，针对 Windows 虚拟机中的 VirtIO GPU 驱动提交了多个关键修复，解决了多个导致系统蓝屏 (BSOD) 的严重问题。

#### PR #1473 - [viogpu] Fix null pointer dereference in VioGpuObj::Init error path
- **状态**: ✅ 已合并 (2026-02-06)
- **问题**: 切换到超出预分配帧缓冲段大小的分辨率时，`VioGpuObj::Init` 错误路径使用未初始化的成员 `m_pSegment`，导致空指针解引用触发 `0x3B SYSTEM_SERVICE_EXCEPTION`。
- **方案**: 修正错误路径使用正确的参数 `pSegment`。

#### PR #1475 - [viogpu] Fix resource leak when framebuffer init fails
- **状态**: ✅ 已合并 (2026-02-09)
- **问题**: `VioGpuObj::Init()` 在 `CreateFrameBufferObj()` 中失败时，已分配的 GPU 资源和 ID 未被清理，导致宿主端资源泄漏。
- **方案**: 在返回 FALSE 前添加 `DestroyResource()` 和 `PutId()` 调用。

#### PR #1479 - [viogpu] Add dynamic framebuffer segment resizing
- **状态**: 🔄 开放中
- **功能**: 作为 PR #1474 (分辨率限制方案) 的替代方案，实现动态帧缓冲区段大小调整，支持 8K+ 高分辨率；添加同步 GPU 命令完成和 indirect descriptor 支持。(+884/-107 行)

#### PR #1474 - [viogpu] Reject resolutions exceeding framebuffer segment capacity
- **状态**: 🔄 开放中
- **功能**: 在 IsSupportedVidPn 中添加分辨率验证，提前拒绝超出帧缓冲容量的分辨率，避免显示进入不可恢复状态。

#### PR #1471 - Fix case-sensitive filename issues for builds on EWDK 25H2
- **状态**: 🔄 开放中
- **功能**: 修复在大小写敏感文件系统上 (如 Linux virtiofs 共享目录) 的 EWDK 构建问题。

### 相关项目：virtio-win-guest-tools-installer (⭐163)

#### PR #85 - Fix driver upgrade failure when drivers are in use (🔄 开放中)
- 修复升级时驱动使用中导致的 1603 错误，改为先安装新文件再移除旧版本。

#### PR #87 - Fix GUI Change/Modify not installing newly selected features (🔄 开放中, 2026-02-09)
- 修复维护模式下新增功能未实际部署的问题，为 MSI 属性添加 `Secure="yes"`。

#### PR #88 - Add optional VioGpu Resolution Service (vgpusrv) feature (🔄 开放中, 2026-02-09)
- 添加 VioGpu 分辨率自动同步服务作为可选子功能，包含 `vgpusrv.exe` 服务和 `viogpuap.exe` 辅助程序。(+200 行)

---

## 2. ansible/ansible-runner (⭐1,050)

**项目简介**: Ansible 执行引擎，Red Hat 官方项目  
**技术栈**: Python, Ansible, TTY/PTY  
**GitHub**: https://github.com/ansible/ansible-runner

### PR #1306 - Fix container --tty detection in subprocess mode

**状态**: 🔄 开放中 (活跃开发中，2026-02-07 更新)  
**PR 链接**: https://github.com/ansible/ansible-runner/pull/1306

**问题描述**
在非交互式环境（如 CI/CD 流水线或系统后台进程）中，`ansible-runner` 在 subprocess 模式下会错误地为容器添加 `--tty` 参数。当 `ansible-navigator` 传入 `input_fd=sys.stdin` 但 stdin 并非真正 TTY 时，容器内的分页器 (如 `less`) 会挂起等待输入。关联 issue: ansible/ansible-navigator#1607。

**解决方案演进**

初始方案 (2023-09) 检查 `sys.stdout.isatty()` 按 runner_mode 决定 TTY 分配，但维护者 @Shrews 提出可能影响 pexpect 密码场景。

重新设计的方案 (2026-02-07) 提取了 `_should_allocate_tty()` 方法，直接检查调用方传入的 `input_fd.isatty()`：
```python
def _should_allocate_tty(self):
    """Determine whether to add --tty to container command."""
    # pexpect mode: always allocate TTY (passwords still work)
    if self.runner_mode == 'pexpect':
        return True
    # subprocess with input_fd: check if fd is actually a TTY
    if hasattr(self, 'input_fd') and self.input_fd:
        return self.input_fd.isatty()
    # no input_fd at all: no TTY (same as pre-b5ead3b behavior)
    return False
```

**设计考量**
- **pexpect 模式**: 始终返回 True（密码交互不受影响）
- **subprocess + input_fd**: 返回 `input_fd.isatty()`（核心修复）
- **无 input_fd**: 返回 False（对 AWX 等不传 input_fd 的调用方无行为变更）

**影响评估**
- ✅ 修复了 Ansible Navigator 在 CI 环境、管道重定向下的挂起问题
- ✅ 提升了工具在无监督环境下的鲁棒性
- ✅ 维护者已完成手动测试验证 (pexpect + 密码、容器 stdin 连接等场景)

---

## 3. gentoo/gentoo (⭐2,328)

**项目简介**: Gentoo Linux 官方项目仓库 (Portage Tree)  
**技术栈**: Shell, OpenRC, Gentoo ebuild  
**GitHub**: https://github.com/gentoo/gentoo

### PR #45057 - kde-plasma/krdp: add OpenRC rc file in 6.5.4

**贡献内容**
为 KDE Plasma 的远程桌面组件 (KRDP) 添加了官方的 OpenRC 启动脚本支持。Gentoo 默认支持 Systemd 和 OpenRC，而许多 KDE 组件初始仅包含 Systemd 单元。

**代码片段 (OpenRC Service)**
```bash
#!/sbin/openrc-run
description="KDE Remote Desktop Server"
command="/usr/bin/krdp-server"
command_background="yes"
pidfile="/run/${RC_SVCNAME}.pid"

depend() {
    need dbus
    use logger
}
```

---

## 4. TeamNewPipe/NewPipeExtractor (⭐1,000+)

**项目简介**: NewPipe 的核心多媒体信息提取库  
**技术栈**: Java, Android, 网络抓取  
**GitHub**: https://github.com/TeamNewPipe/NewPipeExtractor

### PR #936 - [YouTube] Add comment reply count support

**贡献内容**
修复了 YouTube 评论解析器，使其能够正确抓取并显示评论的回复数量。这是实现 NewPipe 完整评论互动功能的基础底层支持。

---

## 🎯 总结

### 核心技术能力展示

1.  **系统级调试**:
    *   能够处理最难调试的 Windows 内核蓝屏问题。
    *   理解驱动程序中的竞态条件和内存泄露。
2.  **跨平台兼容性**:
    *   在 Red Hat 的 Ansible 生态中处理 TTY/PTY 兼容性。
    *   在 Gentoo 社区平衡 Systemd 与 OpenRC 两种不同的初始化系统。
3.  **底层逻辑修复**:
    *   不仅仅是应用层开发，更深入到驱动、执行引擎和协议提取层。

---

**文件版本**: v1.1  
**最后更新**: 2026-02-09

