# 当前个人画像（2026-06-10）

> **用途**: 记录 wiki 中关于 xz-dev / 曾祥哲的最新公开定位。  
> **边界**: 这里只保留适合放入公开开源档案的摘要；本地服务地址、API key、公司内部服务器、同事姓名和临时项目进度不写入 wiki。  
> **最后更新**: 2026-06-10

---

## 1. 当前定位

| 维度 | 当前描述 |
|---|---|
| **姓名 / ID** | 曾祥哲 / Zeng Xiangzhe；GitHub: `xz-dev`；社区用户名常用 `inkflaw` |
| **职业身份** | Full-stack engineer at Capital Dynamics Shanghai；工作覆盖资产管理 PMS 相关工程、供应商/工具选型评估与 AI 工程效率建设 |
| **公开技术主线** | Linux/Gentoo 系统工程 + AI agent infrastructure + 多模型网关/记忆系统 + 开源维护 |
| **开源规模** | GitHub CLI 统计截至 2026-06-10: 347 个公开 PR，81 个公开仓库，累计项目 stars 约 805k |
| **当前工作方式** | Hermes 为主 AI 助手；OpenAI Codex / opencode 作为辅助代码工具；强调测试、证据、上游优先和安全边界 |

---

## 2. 2026 年后的新重心

旧版 wiki 主要把 2025 之后的 AI 工作概括为 **Klavis AI / MCP 基础设施**。这个说法已经偏窄。现在更准确的画像是：

1. **自建 AI agent 基础设施**
   - Hermes 作为主助手与工程入口；
   - Honcho 作为长期记忆/推理框架，拆分 Deriver / Summary / Dialectic / Dream 等模块；
   - Hindsight 作为 MCP 记忆工具，用于手动 retain / recall / reflect；
   - APISIX AI gateway 替代 LiteLLM，形成统一 OpenAI-compatible gateway；
   - OmniRoute / Hermes WebUI / provider 插件贡献集中在模型列表、streaming、API key、usage 统计和 provider 能力暴露。

2. **Agent guardrails / OpenClaw 方向**
   - 关注 prompt injection、工具调用边界、路径访问误报、分阶段目标契约和 sidecar 审计；
   - 倾向 trust-zone / capability separation / taint tracking / network egress control，而不是只靠提示词检测。

3. **Gentoo 与 AI 工具链维护**
   - 高频维护 `opencode-bin`、`anytype-bin`、`lceda-pro` 等包；
   - 将 AI 版本检查、ebuild 生成、`pkgcheck` 与 Podman 容器测试组合成可重复流程；
   - 维护目标从“把包升上去”扩展到“用 AI + 传统工具链稳定追踪快速发布的软件”。

4. **系统/驱动长尾问题定位**
   - VirtIO GPU / FreeBSD virtio_balloon / amdgpu MST DSC / Linux evdev / reframe 等方向继续体现跨层诊断能力；
   - 典型路径是从用户可见症状追到内核、驱动、协议、构建系统或 init 系统。

---

## 3. 当前 AI 基础设施画像

| 层级 | 当前系统 / 项目 | 说明 |
|---|---|---|
| **助手入口** | Hermes | 主日常助手；结合 WebUI、gateway、memory provider、skill library |
| **模型网关** | APISIX AI gateway | 本地统一 OpenAI-compatible gateway；LiteLLM 已退役；公开配置仓库: `xz-dev/apisix-ai-gateway-config`，Hermes provider 插件: `xz-dev/hermes-apisix-provider` |
| **记忆系统** | Honcho + Hindsight | Honcho 做自动 per-turn memory provider；Hindsight 作为 MCP 工具做显式长程认知与反思 |
| **模型策略** | SiliconFlow / Ollama Cloud / OpenAI Codex 等 | 按任务频率和能力分层；便宜高速模型处理高频结构化任务，强模型处理低频推理/规划 |
| **开源反馈** | OmniRoute / Hermes / Honcho / LiteLLM / pi-guardrails | 将自己基础设施中遇到的问题推回上游，尤其是 provider、streaming、模型列表、健康检查和 guardrail 误报 |

---

## 4. 工程风格更新

| 风格 | 当前体现 |
|---|---|
| **证据优先** | 先查源代码、日志、API 返回和 GitHub 状态，再下结论 |
| **数据驱动模型选择** | 通过 json_schema、tool_call、latency、价格、长任务稳定性等实测维度选模型 |
| **上游优先** | 判断 bug 是否已有 upstream 修复；能推上游就不长期保留本地 patch |
| **测试优先** | 部署/修复后必须跑集成测试、端到端验证或可复现命令 |
| **安全边界清晰** | 不把 API key、本地 IP、内部服务器、临时敏感文件写进公开交付物 |
| **成本敏感但不盲目省钱** | 高频模块重视价格，低频质量关键模块接受更强模型 |
| **偏爱新技术** | Hyprland、最新 LLM、AI agent infra、OpenAI Codex / opencode、APISIX gateway 等都会快速试用和实测 |

---

## 5. 与旧版 wiki 的差异

- **PR 统计**: 从旧版 217+ PR 更新为 347 个公开 PR；项目数从 110+ 的旧估计修正为 GitHub CLI 可复现的 81 个公开仓库。
- **AI 方向**: 从“MCP / Klavis AI 贡献”扩展为“AI agent 基础设施、模型网关、记忆系统、guardrails、工具链采购/评估”。
- **基础设施**: LiteLLM 不再是当前核心路径；APISIX AI gateway + Hermes provider 插件成为主要抽象层。
- **开源活跃度**: 2026 年截至 2026-06-10 已有 153 个公开 PR，远高于旧版只覆盖到 4 月的 67+ 估计。
- **职业画像**: 不再只是开源贡献者/全栈开发者，也包括企业 AI 工具选型、PMS 相关工程和工程效率治理。
