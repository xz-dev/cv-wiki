# UpgradeAll - Android 更新系统深度分析

> **核心成就**: 从零创建的模块化 Android 应用更新框架，持续演进 7 年  
> **技术领域**: Android 应用架构、Kotlin/Rust 跨语言、构建系统工程  
> **项目规模**: ⭐1.3k, 活跃用户群体, F-Droid/CoolApk 长期上架

---

## 📊 项目概览

[UpgradeAll](https://github.com/DUpdateSystem/UpgradeAll) 是一个可以检查 Android 应用、Magisk 模块等各类软件更新的工具。作为项目创始人和核心维护者，主导了从 0 到 1 的开发以及持续 7 年的技术演进。

### 核心架构

- **模块化软件源**: 支持 GitHub Release、F-Droid、CoolApk、Google Play 等多种更新源
- **规则引擎**: 用户可自定义更新检测规则
- **Rust getter**: 核心更新检测逻辑用 Rust 实现，通过 JSON-RPC 与 Kotlin 层通信
- **Shizuku 安装**: 支持特权无 root 安装

---

## 🔍 2026-02 重大技术演进

### 1. AGP 9.0 大规模现代化 (2026-02-13)

**背景**: Android Gradle Plugin 9.0 带来了大量破坏性变更，移除了旧版 API，需要全面重构构建系统。

**构建系统变更**:
- 从 `buildscript/classpath` 迁移到 plugins DSL + version catalog (`libs.versions.toml`)
- 移除不兼容的 `kotlin-android` 插件（AGP 9.0 内置 Kotlin 支持）
- 添加 `com.android.legacy-kapt` 用于 DataBinding BR 类生成
- 升级 KSP 到 2.3.5 以兼容 AGP 9.0
- 将 `applicationVariants` 迁移到 `androidComponents` API
- 将 `packagingOptions` 替换为 `packaging` DSL
- 修复所有 10 个模块的 Groovy DSL 语法: `prop value` → `prop = value`

**Kotlin 源码现代化** (跨 22 个文件):
- `GlobalScope` → 结构化并发 (`viewModelScope`, `lifecycleScope`, `applicationScope`)
- `onBackPressed()` → `finish()`
- `onRequestPermissionsResult` → `ActivityResultContracts` API
- `resources.getColor()` → `ContextCompat.getColor()`
- 移除 `threetenabp`，使用 `java.time`
- 移除 `legacy-support-v4` 和 `lifecycle-extensions` 废弃依赖
- `-Xopt-in` → `-opt-in`，移除 `-XXLanguage:+InlineClasses`

**GradleAndroidRustPlugin 兼容性**:
- 上游插件 (MatrixDev) 未发布 AGP 9.0 兼容版本
- 提交并合并 PR #14 迁移插件到 AGP 9.0 新 DSL API
- 通过 JitPack fork + `resolutionStrategy` 引入 0.6.0 版本

### 2. Rust Getter 统一架构 (2026-02-11 ~ 02-15)

**目标**: 将所有 Kotlin Hub 实现统一路由到 Rust getter 的 JSON-RPC 系统。

**架构演进路径**:

```
阶段1: HTTP JSON-RPC 客户端 (2026-02-11)
  Kotlin -> jsonrpc4j (HTTP) -> Rust jsonrpsee server

阶段2: 添加 WebSocket JSON-RPC 客户端 (2026-02-11)
  Kotlin -> WsRpcClient (Ktor WebSocket) -> Rust server
  保留 HTTP 用于 RustDownloader 兼容

阶段3: 纯 WebSocket 传输 (2026-02-11)
  移除 jsonrpc4j/Jackson 依赖
  所有 RPC 通过单一持久 WebSocket 连接
  GetterService 合并为 suspend 接口

阶段4: OutsideProvider 注册 (2026-02-15)
  Kotlin Hub (GooglePlay, CoolApk) -> 注册为 OutsideProvider
  Rust getter -> 通过 HTTP JSON-RPC 回调 Kotlin
  完全统一的 Provider 路由
```

**最终架构**:
```
Kotlin App
  └─ GetterPort (WebSocket JSON-RPC)
      └─ Rust getter (jsonrpsee server)
          ├─ Built-in Providers (GitHub, F-Droid, ...)
          └─ OutsideProviders (via HTTP JSON-RPC callback)
              └─ KotlinHubRpcServer (Ktor CIO)
                  ├─ GooglePlay Hub
                  └─ CoolApk Hub
```

**关键技术决策**:
- WebSocket max message size: 2GB (运行时可配置 via `GETTER_WS_MAX_MESSAGE_SIZE`)
- 使用 `typeOf<T>()` 辅助函数实现泛型 JSON-RPC 反序列化
- 添加 WS 客户端连接测试和 50MB 大消息 echo 测试
- 使用 `serial_test` 确保有状态测试不并行执行

### 3. Rust getter 依赖现代化 (2026-02-11)

- 将 `version-compare` 替换为 `libversion-sys` (系统级版本比较)
- 将 jsonrpsee `ServerBuilder` API 迁移到 v0.26.0
- 修复 HTTPS 测试：`example.com` 的 Cloudflare TLS 证书不在 `webpki-roots` 中，改用 `github.com`

---

## 💡 技术总结

### 架构演进能力
- 7 年间从单体 Kotlin 应用演进到 Kotlin+Rust 混合架构
- 构建系统跟随 AGP 主版本演进，不积累技术债

### 跨语言集成
- Kotlin ↔ Rust 通过 JSON-RPC over WebSocket 通信
- NDK 交叉编译通过 GradleAndroidRustPlugin 自动化
- 双向 RPC 回调 (Rust → Kotlin via OutsideProvider)

### 构建系统工程
- 深入理解 Gradle Plugin 生态和 AGP 内部 API 变迁
- 能够独立修复上游 Gradle 插件的兼容性问题

---

**文件版本**: v2.0  
**最后更新**: 2026-02-19
