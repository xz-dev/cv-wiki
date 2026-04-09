# hid-rgb-ctl

> **定位**: Linux HID RGB 灯光控制 CLI 工具  
> **状态**: 已发布 v0.2.6 (crates.io)  
> **技术栈**: Rust, lexopt + libc (最小依赖)  
> **仓库**: [xz-dev/hid-rgb-ctl](https://github.com/xz-dev/hid-rgb-ctl)

---

## 项目概览

| 属性 | 值 |
|------|-----|
| **语言** | Rust (原 Python，2026-03-31 完整重写) |
| **创建时间** | 2026-03-23 |
| **依赖** | `lexopt` (CLI 解析), `libc` (ioctl) |
| **安装方式** | `cargo install hid-rgb-ctl` |
| **Stars** | 3 |

---

## 技术演进: Python → Rust

### v0.1.x (Python 阶段, 2026-03-23)

- Python 3.9+，零外部依赖 (仅标准库)
- 通过 `/dev/hidrawN` 直接与设备通信
- 支持 HID LampArray + HID LED Page RGB 双协议
- 安装方式: `pipx install`

### v0.2.x (Rust 重写, 2026-03-31 起)

重写动机: 系统级工具更适合编译型语言，减少运行时依赖，提升性能。

**新增特性**:
- **逐灯控制** (`set-lamp`): 通过 `LampMultiUpdateReport` 实现，自动批处理超出单次报告容量的灯组
- **Feature/Output 报告自动检测**: 解析 HID report descriptor 判断设备使用 Feature Report 还是 Output Report
- **值自动缩放**: 根据设备声明的 `LogicalMaximum` 自动缩放颜色值 (如 LED Intensity 0-100)
- **单设备快速发现**: 优化 sysfs I/O，消除冗余内存分配
- **read-after-write 验证**: 写入后读回状态并在不匹配时发出警告

**版本历程**:
- v0.2.3 (03-31): 切换 CI 到 `cargo-zigbuild` 交叉编译
- v0.2.4 (03-31): read-after-write 状态验证
- v0.2.5 (04-01): 消除冗余分配和 sysfs I/O，单设备发现优化
- v0.2.6 (04-01): 简化 ParserState，扁平化 DeviceInfo 结构

---

## 支持的协议

### HID LampArray (Usage Page 0x59)

现代动态灯光标准，来自 [USB HID Usage Tables v1.4](https://usb.org/document-library/hid-usage-tables-14) Section 26。支持设备属性查询、逐灯控制、自主/手动模式切换。

操作流程 (Section 26.6):
1. 读取 `LampArrayAttributesReport` — 获取灯数、设备类型
2. 读取每个灯的 `LampAttributesResponseReport` — 位置、RGB 级别、可编程性
3. 禁用 `AutonomousMode` — 从设备固件接管控制权
4. 发送 `LampRangeUpdateReport` / `LampMultiUpdateReport` 写入颜色
5. 恢复 `AutonomousMode` (可选)

### HID LED Page RGB (Usage Page 0x08, Section 11.7)

传统 RGB LED 控制协议。RGB LED 集合 (Usage 0x52) 直接包含 Red/Blue/Green 通道和可选的亮度控制。

---

## 技术亮点

- **自动设备发现**: 通过解析 HID report descriptor 识别设备，不硬编码 vendor/product ID — 自动支持所有合规设备
- **最小依赖**: 仅 `lexopt` (CLI 解析) 和 `libc` (ioctl)，无 runtime 开销
- **双协议支持**: 同时处理新旧两种 HID 标准
- **跨编译**: 使用 cargo-zigbuild 生成多架构二进制
- **代码质量**: Rust 类型安全 + clippy lint

---

## 已验证设备

| 设备 | 总线 | VID:PID | 协议 | 灯数 |
|------|------|---------|------|------|
| ASUS Vivobook S 16 (M5606WA) 键盘 | I2C | 0B05:5570 | LampArray | 1 (单区域) |

---

## 使用示例

```sh
hid-rgb-ctl list              # 列出检测到的设备
hid-rgb-ctl get               # 显示设备属性和灯信息
hid-rgb-ctl set red           # 预设颜色
hid-rgb-ctl set 255 165 0     # RGB 值
hid-rgb-ctl set ff6400        # 十六进制
hid-rgb-ctl set cyan -i 128   # 自定义亮度
hid-rgb-ctl set-lamp 0 red    # 逐灯控制 (LampArray)
hid-rgb-ctl auto off          # 接管设备控制 (LampArray)
```

---

## 关联项目

- [numlockw](./numlockw.md) — 同属 Linux 输入子系统领域
- [python-evdev PR #251](https://github.com/gvalkov/python-evdev/pull/251) — 同为 HID/evdev 设备交互

---

**文件版本**: v2.0  
**最后更新**: 2026-04-09
