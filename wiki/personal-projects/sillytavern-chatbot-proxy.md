# SillyTavern ChatBot-Proxy

> **定位**: AI 虚拟伴侣异步通信系统  
> **状态**: 完全可用，稳定运行  
> **技术栈**: TypeScript (Koishi) + JavaScript (SillyTavern Extension) + SQLite + ffmpeg  
> **代码量**: 2500+ 行

---

## 📊 项目概览

| 属性 | 值 |
|------|-----|
| **Koishi 插件** | [SillyTavern-ChatBot-Proxy-koishi-plugin](https://github.com/xz-dev/SillyTavern-ChatBot-Proxy-koishi-plugin) |
| **ST 扩展** | [SillyTavern-ChatBot-Proxy-sillytavern-plugin](https://github.com/xz-dev/SillyTavern-ChatBot-Proxy-sillytavern-plugin) |
| **语言** | TypeScript (1850行) + JavaScript (700行) |
| **创建时间** | 2026-03-14 |
| **依赖** | Koishi ≥4.15, fluent-ffmpeg, @ffmpeg-installer/ffmpeg |

---

## 功能列表

### 已实现
- 双向文字消息桥接 (平台用户 ↔ SillyTavern AI 角色)
- TTS 语音消息转发 (MP3 → OGG Opus 自动转码)
- STT 语音识别 (Groq / OpenAI Whisper)
- 图片消息转发 (含 Stable Diffusion 生成图)
- AI 推理过程展示 (平台原生格式适配)
- 输入状态指示器 (心跳驱动)
- 频道 ↔ 对话绑定 (SQLite 持久化)
- 离线消息恢复 (自动补发错过的消息)
- Bot 头像自动同步 (跟随 ST 角色头像)
- 断线自动重连 (指数退避)
- 多平台支持: Telegram, Discord, QQ, Matrix 等

### 规划中 (下一阶段)
- pipecat 集成 → 实时电话/视频通话
- AI 自主调度互动 (主动发起对话)
- 多模态实时交互

---

## 架构简图

```
用户 (Telegram/Discord/QQ/Matrix)
    ↕ Satori 协议
Koishi 服务端 (WebSocket Server + SQLite + ffmpeg)
    ↕ WebSocket JSON
SillyTavern 浏览器 (事件 Hook + 消息队列)
    ↕ LLM API
AI 模型 (OpenAI / Claude / 本地)
```

---

## 深度分析

**[→ 完整架构分析](../deep-dive/sillytavern-chatbot-proxy.md)**: WebSocket 协议设计、串行消息队列、SQLite 持久化、ffmpeg 音频转码、多平台差异适配、离线恢复、上游 PR 贡献、pipecat 演进路线

---

**文件版本**: v1.0  
**最后更新**: 2026-03-23
