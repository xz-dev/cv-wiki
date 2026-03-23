# hid-rgb-ctl

> **定位**: Linux HID RGB 灯光控制 CLI 工具  
> **状态**: 已发布 v0.1.2  
> **技术栈**: Python 3.9+, 零外部依赖  
> **仓库**: [xz-dev/hid-rgb-ctl](https://github.com/xz-dev/hid-rgb-ctl)

---

## 📊 项目概览

| 属性 | 值 |
|------|-----|
| **语言** | Python |
| **创建时间** | 2026-03-23 |
| **依赖** | 无 (标准库 only) |
| **安装方式** | `pipx install git+https://github.com/xz-dev/hid-rgb-ctl.git` |

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
- **零依赖**: 仅使用 Python 3.9+ 标准库，直接通过 `/dev/hidrawN` 与设备通信
- **双协议支持**: 同时处理新旧两种 HID 标准
- **代码质量**: ruff lint CI, dataclass 数据模型, context manager 资源管理

---

## 已验证设备

| 设备 | 总线 | VID:PID | 协议 | 灯数 |
|------|------|---------|------|------|
| ASUS Vivobook S 16 (M5606WA) 键盘 | I2C | 0B05:5570 | LampArray | 1 (单区域) |

---

## 使用示例

```sh
hid-rgb-ctl list              # 列出检测到的设备
hid-rgb-ctl set red           # 预设颜色
hid-rgb-ctl set 255 165 0     # RGB 值
hid-rgb-ctl set ff6400        # 十六进制
hid-rgb-ctl set cyan -i 128   # 自定义亮度
hid-rgb-ctl auto off          # 接管设备控制 (LampArray)
```

---

**文件版本**: v1.0  
**最后更新**: 2026-03-23
