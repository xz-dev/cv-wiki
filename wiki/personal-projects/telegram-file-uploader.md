# TelegramFileUploader

> **定位**: GitHub Action + 独立 CLI 工具，通过 Telethon 上传文件到 Telegram  
> **状态**: 活跃维护  
> **技术栈**: Python, Telethon, Docker, GitHub Actions  
> **仓库**: [xz-dev/TelegramFileUploader](https://github.com/xz-dev/TelegramFileUploader) (8 Stars)

---

## 项目概览

| 属性 | 值 |
|------|-----|
| **语言** | Python |
| **创建时间** | 2024-03-04 |
| **使用方式** | GitHub Action / 独立 CLI / Docker |
| **依赖** | Telethon (Telegram MTProto 客户端) |

---

## 核心功能

- **多文件分组上传**: 将多个文件作为单条分组消息 (album) 发送
- **上传进度报告**: 实时显示上传进度
- **消息 URL 返回**: 上传完成后返回消息 URL 和 ID
- **GitHub Actions 输出**: 为下游 step 提供 outputs
- **Docker 支持**: 容器化运行

## 使用场景

- CI/CD 构建产物自动推送到 Telegram 频道
- 日志文件归档到 Telegram 群组
- 自动化发布流程的通知集成

---

## GitHub Action 用法

```yaml
- uses: xz-dev/TelegramFileUploader@main
  with:
    to-who: ${{ secrets.TELEGRAM_CHAT_ID }}
    message: "Build artifacts for ${{ github.sha }}"
    files: |
      build/output.apk
      build/output.aab
  env:
    API_ID: ${{ secrets.API_ID }}
    API_HASH: ${{ secrets.API_HASH }}
    BOT_TOKEN: ${{ secrets.BOT_TOKEN }}
```

---

**文件版本**: v1.0  
**最后更新**: 2026-04-09
