# Windows驱动开发

> 深入系统内核层，修复复杂的 BSOD 问题，优化 GPU 虚拟化性能

---

## 📊 技术领域概览

- **核心项目**: virtio-win/kvm-guest-drivers-windows (⭐2,550), virtio-win/virtio-win-guest-tools-installer (⭐163)
- **主要角色**: 驱动稳定性修复、高分辨率支持、资源管理优化、安装程序改进
- **技术栈**: C, C++, Windows DDK, WDM/WDF, WDDM, DirectX, WiX Installer
- **贡献时间**: 2025-2026年
- **贡献亮点**: 修复多个严重的蓝屏问题，实现8K分辨率支持，改进驱动安装体验

---

## 1. VirtIO GPU 驱动 BSOD 修复系列

### 背景介绍

VirtIO GPU 是一个用于 KVM/QEMU 虚拟机的显卡驱动，提供高性能 2D/3D 图形加速能力。在高负载或特殊场景下，驱动中的一些竞态条件和错误处理路径会导致 Windows 虚拟机蓝屏。

### 重点贡献

#### PR #1473 - [viogpu] Fix null pointer dereference in VioGpuObj::Init error path
- **状态**: ✅ 已合并 (2026-02-06)
- **BSOD 代码**: `0x3B SYSTEM_SERVICE_EXCEPTION`
- **症状**: 切换到超出预分配帧缓冲段大小的分辨率时，`VioGpuObj::Init` 错误路径使用未初始化的成员 `m_pSegment` 而非参数 `pSegment`，导致空指针解引用
- **改动**: +1/-1 行，viogpu/common/viogpu_queue.cpp
- **已知限制**: 修复阻止了崩溃，但尚未解决切换到超大分辨率再切回较小分辨率时显示输出无法恢复的问题

#### PR #1475 - [viogpu] Fix resource leak when framebuffer init fails
- **状态**: ✅ 已合并 (2026-02-09)
- **问题**: 当 `VioGpuObj::Init()` 在 `CreateFrameBufferObj()` 中失败时，之前分配的 GPU 资源和 ID 未被清理，导致宿主端资源泄漏
- **方案**: 在返回 FALSE 前添加 `DestroyResource()` 和 `PutId()` 调用
- **改动**: +17/-8 行，viogpu/viogpudo/viogpudo.cpp

#### PR #1488 - [viogpu] Use infinite wait for device response in release builds
- **状态**: ❌ 已关闭 (未合并)
- **分析**: 当 AskEdidInfo 或 AskDisplayInfo 等待设备响应超时后，缓冲区的 resp_buf 被释放并置 NULL，但缓冲区仍留在 virtio 队列中。设备最终完成请求并触发中断时，DpcRoutine 出队该缓冲区并尝试访问 resp->type，导致空指针解引用 (BSOD 0xD1)
- **方案**: 在 Release 构建中使用无限等待避免竞态条件

#### PR #1479 - [viogpu] Add dynamic framebuffer segment resizing
- **状态**: 🔄 开放中

**功能增强**:
- 作为 PR #1474 (分辨率限制方案) 的替代方案：不拒绝超大分辨率，而是动态调整 m_FrameSegment 大小
- 添加 `VioGpuMemSegment::TakeFrom()` 实现安全的所有权转移
- 添加同步 GPU 命令完成操作 (DetachBackingSync/DestroyResourceSync/DestroyFrameBufferObjSync)，防止 QEMU 在新资源绑定到复用内存时仍在访问旧段内存
- 启用 `VIRTIO_RING_F_INDIRECT_DESC` 支持 8K+ 分辨率的大型 scatter-gather 列表
- **改动**: +884/-107 行，4个文件

**实现细节**:
```cpp
// 动态计算所需framebuffer大小
SIZE_T GetRequiredFramebufferSize(UINT width, UINT height, UINT bpp) {
    SIZE_T bytesPerPixel = bpp / 8;
    SIZE_T stride = ALIGN_UP(width * bytesPerPixel, 4); // 4字节对齐
    return stride * height;
}

// 当请求更大分辨率时重新分配
NTSTATUS ResizeFramebufferIfNeeded(UINT newWidth, UINT newHeight) {
    SIZE_T newSize = GetRequiredFramebufferSize(newWidth, newHeight, m_bpp);
    
    if (newSize > m_fbSize) {
        // 释放旧buffer
        if (m_pFrameBuffer) {
            // 先通知GPU释放资源
            NotifyGpuResourceRelease();
            // 再释放内存
            FreeMemory();
        }
        
        // 分配新buffer
        m_fbSize = newSize;
        NTSTATUS status = AllocateMemory(m_fbSize);
        if (!NT_SUCCESS(status)) {
            return status;
        }
        
        // 通知GPU新分配
        return CreateGpuResource();
    }
    
    return STATUS_SUCCESS;
}
```

#### 其他重要修复

1. **PR #1474** (🔄 开放中): 在 IsSupportedVidPn 中添加分辨率验证，拒绝超出帧缓冲段大小的分辨率切换请求，防止显示进入不可恢复状态 (+46/-0 行)
2. **PR #1471** (🔄 开放中): 修复在 EWDK 25H2 大小写敏感文件系统上的构建问题 (重命名文件以匹配 #include 引用)

### 相关工作: virtio-win-guest-tools-installer (⭐163)

#### PR #85 - Fix driver upgrade failure when drivers are in use (🔄 开放中)
- **问题**: 升级 virtio-win 驱动时，当驱动正在使用中 (如 viostor 作为启动盘) 会报 1603 错误。UninstallDriverPackages 自定义操作无法卸载正被系统使用的驱动
- **方案**: 将 MajorUpgrade Schedule 从 `afterInstallInitialize` 改为 `afterInstallExecute`，先安装新文件再移除旧版本；将 UninstallDriverPackages Return 从 `check` 改为 `ignore`；启用 `DIURFLAG_NO_REMOVE_INF` 标志延迟到重启时清理 INF
- **改动**: +11/-4 行，4个文件

#### PR #87 - Fix GUI Change/Modify not installing newly selected features (🔄 开放中, 2026-02-09)
- **问题**: 在维护模式 (添加/删除程序中的"更改") 选择之前未安装的功能后，UI 显示已安装但实际文件和服务未部署。MSI 日志显示 `Ignoring disallowed property REGISTRY_PRODUCT_NAME`
- **根因**: `REGISTRY_PRODUCT_NAME` 和 `REGISTRY_CURRENT_BUILD_NUMBER` 用于组件 `<Condition>` 中匹配正确的 OS 变体。维护模式安装时，MSI 客户端传递属性给服务端 (提权安装进程)，未标记为 `Secure` 的属性会被服务端丢弃。首次安装不受影响因为服务端会重新执行 `AppSearch`，但维护模式跳过了 `AppSearch`
- **方案**: 为两个属性定义添加 `Secure="yes"`
- **改动**: +2/-2 行，properties.wxs

#### PR #88 - Add optional VioGpu Resolution Service (vgpusrv) feature (🔄 开放中, 2026-02-09)
- **功能**: 添加 VioGpu 分辨率服务 (vgpusrv) 作为 Viogpudo 驱动的可选子功能，默认未选中 (`Level='1001'`)
- **安装内容**: `vgpusrv.exe` (Windows 服务，自动启动) + `viogpuap.exe` (辅助可执行文件)，提供虚拟机窗口大小与显示分辨率的自动同步
- **设计决策**: 使用子功能方式 (非 `extra_components`)，允许在功能树中独立切换；无需修改构建脚本，新 .wxs 文件由通配符自动发现
- **改动**: +200/-0 行，5个文件 (3个新增 .wxi/.wxs 模板)
- **依赖**: GUI 更改/修改功能依赖 PR #87 的 `Secure` 属性修复

## 2. 技术深度分析

### Windows 驱动开发流程掌握

- **熟悉 Windows DDK/WDK 工具链**
  - Visual Studio 与 WDK 集成
  - EWDK 构建系统
  - inf2cat, signcode 工具

- **熟悉驱动调试技术**
  - WinDbg + KD 内核调试
  - 使用 VirtualKD 调试虚拟机
  - 分析 minidump 文件 (BlueScreenView)

### 驱动架构理解

- **图形驱动架构**
  - VirtIO 驱动模型
  - WDDM 显示驱动接口
  - DirectX 与显卡交互

- **内存管理与同步**
  - 驱动中的内存分配/释放策略
  - 使用 Spin Lock 和 Mutex 控制并发
  - IRQL 级别切换与 DPC

## 🎯 总结与技能展示

### 核心技能
- 深入掌握 Windows 内核编程模型
- 理解虚拟化环境下的硬件模拟机制
- 能够分析和修复复杂的蓝屏问题
- 熟悉驱动程序生命周期与资源管理

### 应用场景
- 虚拟化环境中的 Windows 驱动开发
- 高性能图形系统优化
- 可靠性和稳定性保障

---

**文件版本**: v1.1  
**最后更新**: 2026-02-09

