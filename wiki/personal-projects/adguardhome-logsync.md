# AdGuardHome-LogSync - 多实例查询日志同步工具

> **定位**: 在多个 AdGuard Home 实例之间同步 query log，并按保留时间自动轮转
> **技术栈**: Python, async processing, streaming file merge, CLI
> **仓库**: [xz-dev/AdGuardHome-LogSync](https://github.com/xz-dev/AdGuardHome-LogSync)
> **PyPI**: [adguardhome-logsync](https://pypi.org/project/adguardhome-logsync/)

---

## 项目概览

当多个 AdGuard Home 实例共同服务一个网络时，每个实例都会产生独立 `querylog.json`。`AdGuardHome-LogSync` 用于把这些日志合并成统一视图，同时保留备份并删除超出保留时间的旧记录。

| 属性 | 值 |
|------|-----|
| 语言 | Python |
| 安装方式 | `pipx install adguardhome-logsync` / `pip install adguardhome-logsync` |
| 输入 | AdGuard Home JSON query log |
| 输出 | 合并、排序、过滤后的 query log |
| 默认保留时间 | 604800 秒（7 天） |

---

## 核心功能

- 备份当前 query log；
- 搜索 backup 目录内多个实例的 query log；
- 合并多个日志文件；
- 按 `--retention` 删除过期记录；
- 使用临时文件安全替换原始日志；
- 支持大文件 streaming，避免一次性读入内存；
- 支持 systemd timer / cron 自动化。

---

## 使用方式

```bash
adguardhome-logsync   --name genx   --path ~/adg/workdir/data/querylog.json   --backup ~/adg/workdir/data/backup   --retention 604800
```

常见保留时间：

| 周期 | 秒数 |
|------|------|
| 1 小时 | 3600 |
| 12 小时 | 43200 |
| 1 天 | 86400 |
| 1 周 | 604800 |
| 1 月 | 2592000 |

---

## 工作流程

```text
读取当前实例 querylog
  → 写入带实例名的备份
    → 扫描 backup 目录所有 querylog
      → streaming merge
        → 按时间过滤过期记录
          → 写临时文件
            → 原子替换原始 querylog
```

项目结构来自上游 README：

```text
AdGuardHomeLogSync/
├── main.py
├── utils/
│   ├── querylog_copy.py
│   └── querylog_merge.py
├── pyproject.toml
└── README.md
```

---

## 技术亮点

| 能力 | 体现 |
|------|------|
| 文件安全 | 先备份，再临时文件替换，避免损坏原日志 |
| 大文件处理 | streaming/chunk 处理，降低内存峰值 |
| 并发处理 | 多日志文件异步处理，提高合并效率 |
| 运维集成 | CLI + systemd timer/cron，适合家庭/服务器长期运行 |

---

## 关联阅读

- [个人项目索引](../README.md#个人项目详解)
- [Python 技术栈索引](../README.md#按技术栈查找)
- [TelegramFileUploader](./telegram-file-uploader.md) — 同属 Python 自动化工具

---

**文件版本**: v1.0
**最后更新**: 2026-06-10
