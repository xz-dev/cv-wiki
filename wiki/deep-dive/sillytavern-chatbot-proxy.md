# SillyTavern ChatBot-Proxy - 深度架构分析

> **核心成就**: 设计并实现完全可用的 AI 虚拟伴侣异步通信系统  
> **技术领域**: 实时通信架构、跨平台机器人框架、音频处理、事件驱动设计  
> **代码规模**: 双端 2500+ 行 (TypeScript 1850行 + JavaScript 700行)  
> **项目状态**: 完全可用，已在 Telegram/Discord 等平台上稳定运行

---

## 📊 项目愿景与演进路线

### 当前阶段：异步通信桥接 (已完成)

基于 Koishi 机器人框架，实现 SillyTavern AI 角色 ↔ 即时通讯平台的双向桥接，支持文字、语音、图片、TTS/STT 的完整交互链路。

### 下一阶段：实时通信 (规划中)

用 **pipecat** 替代 SillyTavern 的 OpenAI API 层，突破机器人框架只能异步通信的限制。需要新开独立项目，因为复杂度已超出插件形态：

- 实时电话和视频通话
- AI 自主规划时间发起互动
- 多模态实时交互（语音 + 视觉）

---

## 🏗️ 系统架构

```
用户 (Telegram / Discord / QQ / Matrix / ...)
        │
        ▼
┌─── Koishi 服务端 (Node.js) ──────────────────────────┐
│  SillyTavern Bridge Plugin (TypeScript, 1850行)       │
│  ├─ WebSocket Server (JSON 协议 + RFC 6455 ping/pong) │
│  ├─ SQLite (st_bindings 频道绑定, st_status_msgs)     │
│  ├─ ffmpeg 音频转码 (MP3 → OGG Opus 语音消息)         │
│  ├─ 离线消息恢复 (getMessageIter + lastSeenMessageId) │
│  ├─ 输入状态指示器 (心跳驱动, 跨平台适配)              │
│  ├─ Bot 头像自动同步 (Telegram/Discord API)            │
│  └─ Satori 协议抽象 → 多平台 Bot 适配                 │
└─────────────────────────┬────────────────────────────┘
                          │ WebSocket (ws://host:5140/st-proxy?key=xxx)
                          ▼
┌─── 浏览器 (SillyTavern) ────────────────────────────┐
│  Koishi Bridge Extension (JavaScript, 700行)          │
│  ├─ Hook ST 事件系统 (消息/TTS/生成状态)               │
│  ├─ 串行消息队列 (防止并发 Generate() 调用)            │
│  ├─ STT 语音转文字 (Groq / OpenAI Whisper)            │
│  ├─ TTS 音频捕获 (tts_audio_ready 事件)               │
│  ├─ 断线重连 + 离线消息缓冲 (指数退避, 最大30s)       │
│  └─ Monkey-patch HTMLMediaElement.play (绕过自动播放)  │
│                                                       │
│  SillyTavern Core                                     │
│  ├─ LLM API (OpenAI / Claude / 本地模型)               │
│  ├─ TTS (ElevenLabs / Edge / etc.)                    │
│  └─ 角色管理 / 对话历史 / 工具调用                     │
└───────────────────────────────────────────────────────┘
```

---

## 🔍 核心技术分析

### 1. WebSocket 双向协议设计

**消息类型 (Channel → ST)**:
- `send_combined_message`: 携带 text/images/audio/files，触发 AI 生成
- `validate_chat` / `list_chats` / `get_avatar`: 请求-响应模式 (requestId + 15s 超时)

**消息类型 (ST → Channel)**:
- `ai_message`: AI 文本回复 + 图片 + 推理过程
- `ai_tts`: Base64 音频数据
- `generation_started`: 输入状态心跳 (每 2s)

**健康检查**: RFC 6455 协议级 ping/pong (可配置间隔，默认 10s)。若 pong 未在下一个 ping 周期前到达，判定连接死亡并终止。

### 2. 串行消息队列

浏览器端维护了一个**严格串行的入站消息队列**，确保：
- 同时只有一个 `Generate()` 调用在执行（LLM 不支持并发生成）
- 来自多个平台用户的消息按到达顺序排队处理
- 每条消息处理完成后，自动切换回原始聊天窗口

### 3. SQLite 持久化与离线恢复

**数据表**:
- `st_bindings`: `(platform, channelId) → stChatId`，唯一约束，存储 `lastMessageId`
- `st_status_msgs`: 状态通知消息 ID 持久化，支持跨重启删除旧通知

**离线恢复流程**:
1. Bot 重连后，通过 `getMessageIter()` 遍历频道最近消息
2. 收集 `lastSeenMessageId` 之后的所有错过消息
3. 打包为带 ISO 8601 时间戳的合并消息，一次性发送给 ST

### 4. 音频管线

```
[用户语音消息] → Koishi 下载 → Base64 → WebSocket → ST 扩展
    → STT (Groq/OpenAI Whisper) → 文字注入 → LLM 生成
    → TTS (ElevenLabs/Edge) → tts_audio_ready 事件
    → Base64 → WebSocket → Koishi
    → fluent-ffmpeg (MP3 → OGG Opus) → 语音消息回复
```

- MD5 去重：相同音频不重复发送（per-channel, per-messageId）
- 语音消息自动关联到对应的文本消息（通过 `stMsgId → platformMsgId` 缓存映射）

### 5. 多平台差异化适配

| 功能 | Telegram | Discord | Matrix |
|------|----------|---------|--------|
| AI 推理过程 | `<blockquote expandable>` | `> *italic quote*` | `<blockquote><em style="color:gray">` |
| 静默通知 | `disable_notification: true` | `flags: 1 << 12` | `msgtype: 'm.notice'` |
| 输入指示器 | `sendChatAction({action: 'typing'})` | `triggerTypingIndicator()` | — |
| Bot 头像同步 | `setMyProfilePhoto` (multipart) | `modifyCurrentUser({avatar})` | — |
| 语音消息格式 | OGG Opus | OGG Opus | OGG Opus |

### 6. 事件驱动的浏览器端 Hook

ST 扩展通过多种机制与 SillyTavern 交互：

- **ST 事件系统**: `USER_MESSAGE_RENDERED`, `CHARACTER_MESSAGE_RENDERED`, `CHAT_CHANGED` 等
- **MutationObserver**: 监听 `body[data-generating]` 属性变化检测生成状态
- **Monkey-patch**: 覆盖 `HTMLMediaElement.prototype.play` 防止 TTS 队列因浏览器自动播放策略而阻塞
- **DataTransfer API**: 模拟文件拖拽附件注入

### 7. 输入状态指示器

基于心跳的两端协作机制：
- ST 端：AI 生成期间每 2s 发送 `generation_started` 心跳
- Koishi 端：收到心跳后启动 typing 循环（每 4s 发送平台原生 typing action）
- 自动停止：8s 无心跳 → 停止，或达到 3 分钟最大时长

---

## 🔗 上游贡献 (SillyTavern, 24.7k Stars)

为了让桥接系统正常工作，向 SillyTavern 上游提交了 5 个 PR（3 个已合并）：

| PR | 动机 | 状态 |
|----|------|------|
| #5309 | TTS 扩展不发出事件 → 无法捕获音频转发到平台 | ✅ 已合并 |
| #5316 | 需要 SiliconFlow.cn 作为 LLM 后端 | ✅ 已合并 |
| #5334 | xAI 模型返回 500 错误影响使用 | ✅ 已合并 |
| #5333 | 流式 tool call 后事件丢失 → 平台收不到 AI 回复 | 🔄 开放中 |
| #5308 | #5333 的初版，被更完整的方案替代 | ❌ 已关闭 |

---

## 💡 技术选型决策

### 为什么选择 Koishi 而非自研多平台适配？

- **Satori 协议抽象**: 单一 API 支持 Telegram/Discord/QQ/Matrix/LINE/Slack 等 10+ 平台
- **内置基础设施**: 数据库抽象、HTTP/WS 路由、中间件管线、Bot 生命周期管理
- **插件生态**: 可与社区的 2000+ 插件组合使用
- **避免重新造轮子**: 各平台 API 的差异化处理（文件上传、消息格式、权限模型）由框架层解决

### 为什么下一阶段需要新开项目？

机器人框架的本质是**异步消息传递**——发一条、等一条。这个模型无法支撑：
- 实时双向音频流（电话通话需要 <200ms 延迟）
- 实时视频帧传输
- AI 主动发起互动的调度系统

pipecat 提供了 WebRTC/SIP 级别的实时媒体管线，需要与 LLM、TTS、STT 深度集成，架构完全不同于当前的消息桥接模式。

---

## 🎯 技能展示

### 全栈能力
- 浏览器端扩展 (JavaScript, DOM API, WebSocket)
- 服务端插件 (TypeScript, Node.js, SQLite)
- 音频工程 (ffmpeg 转码, STT/TTS 集成)
- 跨平台适配 (Telegram/Discord/Matrix API 差异处理)

### 协议设计
- WebSocket 请求-响应模式 (requestId + 超时)
- 心跳健康检查 (RFC 6455 ping/pong)
- 串行化保证 (消息队列 + 互斥锁)

### 工程实践
- 持久化状态管理 (SQLite, 跨重启恢复)
- 优雅降级 (断线重连 + 指数退避 + 离线缓冲)
- Monkey-patching (绕过浏览器限制而非放弃功能)

---

**文件版本**: v1.0  
**最后更新**: 2026-03-23
