# Android生态

> 创建实用工具增强开源应用体验，从视频客户端到应用更新系统

---

## 📊 技术领域概览

- **核心项目**: UpgradeAll (⭐1.3k), NewPipe(Extractor), bilimiao2
- **主要贡献**: 功能增强, UI/UX优化, 构建系统改进
- **技术栈**: Kotlin, Java, Android SDK, Gradle
- **活跃时间**: 2019-2026（持续活跃）
- **相关认证**: Android 开发经验 5年+
- **最新动态**: AGP 9.0 大规模现代化升级、Rust getter 统一架构 (2026-02)

---

## 1. UpgradeAll - 软件更新检查工具

[UpgradeAll](https://github.com/DUpdateSystem/UpgradeAll) (⭐1.3k) 是一个可以检查 Android 应用、Magisk 模块等各类软件更新的工具，是本人创立的核心项目。

### 项目亮点

- **模块化架构**: 支持多种软件源的可扩展系统
- **自动更新检测**: 批量检查多个应用的更新状态
- **自定义规则**: 用户可添加自定义软件源
- **多种安装方式**: 支持 Shizuku 特权安装

### 技术实现

**云规则系统**:
```kotlin
class CloudRuleManager(
    private val ruleRepositoryUrl: String,
    private val api: RuleApi,
    private val db: AppDatabase
) {
    /**
     * 获取并解析云端规则
     */
    suspend fun fetchCloudRules(): List<CloudRule> = withContext(Dispatchers.IO) {
        try {
            val response = api.getRepositoryInfo(ruleRepositoryUrl)
            if (!response.isSuccessful) {
                throw Exception("获取规则失败: ${response.code()}")
            }
            
            val repoInfo = response.body() ?: throw Exception("空响应")
            
            // 解析规则
            return@withContext repoInfo.rules.map { rawRule ->
                CloudRule(
                    id = rawRule.id,
                    name = rawRule.name,
                    description = rawRule.description,
                    webUrl = rawRule.webUrl,
                    targetType = TargetType.valueOf(rawRule.targetType),
                    config = parseRuleConfig(rawRule.config)
                )
            }
        } catch (e: Exception) {
            throw RuleFetchException("获取云规则失败", e)
        }
    }
    
    /**
     * 将云端规则保存到本地数据库
     */
    suspend fun saveCloudRulesToDb(rules: List<CloudRule>) = withContext(Dispatchers.IO) {
        db.ruleDao().insertAll(rules.map { it.toDbEntity() })
    }
}
```

**应用安装管理**:
```kotlin
class AppInstaller(
    private val context: Context,
    private val packageManager: PackageManager
) {
    /**
     * 使用Shizuku特权安装应用
     */
    suspend fun installWithShizuku(apkFile: File): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            if (!ShizukuManager.isShizukuAvailable()) {
                return@withContext Result.failure(
                    InstallException("Shizuku服务不可用")
                )
            }
            
            // 获取特权会话
            val sessionId = ShizukuServiceManager.getService()
                .createSession(apkFile.absolutePath)
            
            // 启动安装
            val success = ShizukuServiceManager.getService()
                .startInstall(sessionId)
            
            return@withContext if (success) {
                Result.success(Unit)
            } else {
                Result.failure(InstallException("安装失败"))
            }
        } catch (e: Exception) {
            return@withContext Result.failure(
                InstallException("安装过程出错", e)
            )
        }
    }
}
```

### 2026-02 重大更新: AGP 9.0 现代化升级

对整个项目进行了大规模构建系统现代化和架构重构：

**构建系统升级**:
- 升级到 **AGP 9.0 + Gradle 9.3.1 + Kotlin 2.3.10**
- 将 `buildscript/classpath` 迁移到 plugins DSL 和 version catalog (`libs.versions.toml`)
- 移除不兼容的 `kotlin-android` 插件，使用 AGP 9.0 内置 Kotlin 支持
- 添加 `com.android.legacy-kapt` 用于 DataBinding BR 类生成
- 修复 GradleAndroidRustPlugin 对 AGP 9.0 的兼容性（通过 JitPack fork）

**Kotlin 代码现代化** (跨 22 个文件):
- 将 `GlobalScope` 替换为结构化并发 (`viewModelScope`, `lifecycleScope`, `applicationScope`)
- 将 `onBackPressed()` 替换为 `finish()`
- 迁移权限请求到 `ActivityResultContracts` API
- 移除 `threetenabp`，使用 `java.time`
- 修复 `nonTransitiveRClass` 引用

### 2026-02 Rust Getter 统一架构

将 Kotlin Hub 实现统一到 Rust getter 的 JSON-RPC 系统中：

**架构变更**:
```
Kotlin -> GetterPort (WebSocket JSON-RPC) -> Rust Provider Map ->
          OutsideProvider -> HTTP JSON-RPC -> KotlinHubRpcServer -> Hub impls
```

- 新增 `KotlinHubRpcServer`: 基于 Ktor CIO 的 HTTP JSON-RPC 服务器
- 重写 `ClientProxyApi` 将所有方法委托给 `getterPort`（移除 hubMap、getHub、NoFunction 等旧逻辑）
- getter 端新增 `register_provider` 和 `get_download` JSON-RPC 方法
- 实现 `OutsideProvider` 通过 HTTP JSON-RPC 回调到 Kotlin

**传输层重构** (2026-02-11):
- 将双 HTTP+WebSocket 架构替换为纯 WebSocket 传输
- `GetterService` 合并为 suspend 接口
- WebSocket 最大消息大小设为 2GB（支持大型数据传输）
- 添加 WebSocket 客户端连接和消息大小限制测试

### 社区影响

- GitHub 星标 1,300+
- 活跃用户群体
- 衍生项目：UpgradeAll-rules（社区规则库）
- CoolApk 和 F-Droid 上长期受欢迎

## 2. NewPipe/NewPipeExtractor - 开源YouTube客户端

为 [NewPipe](https://github.com/TeamNewPipe/NewPipe) (⭐27k+) 及其解析器贡献评论相关功能增强。

### PR #936: YouTube评论回复支持

为 YouTube 评论系统添加了回复计数功能，使用户能够查看并加载评论的回复。

**技术难点**:
- 逆向分析 YouTube 网页/移动版 API
- 处理动态生成的内容
- 兼容无回复评论的情况

**核心代码示例**:
```java
@Override
public InfoItemsPage<CommentsInfoItem> getPage(final Page page) throws IOException, ExtractionException {
    if (page == null || isNullOrEmpty(page.getUrl())) {
        throw new IllegalArgumentException("Page doesn't contain an URL");
    }
    
    final List<CommentsInfoItem> commentsItems = new ArrayList<>();
    final String commentsToken = page.getUrl();
    final JsonObject jsonResponse = getJsonResponse(commentsToken);
    
    // 处理评论数据
    final JsonObject content = jsonResponse
            .getObject("response")
            .getObject("continuationContents");
    
    final JsonArray commentItemsArray = content
            .getObject("commentRepliesContinuation")
            .getArray("contents");
    
    // 提取回复数据
    for (Object object : commentItemsArray) {
        final JsonObject commentItemObject = (JsonObject) object;
        final JsonObject commentRenderer = commentItemObject
                .getObject("commentRenderer");
        
        final CommentsInfoItem commentsInfoItem = extractCommentInfoItem(commentRenderer);
        commentsItems.add(commentsInfoItem);
    }
    
    // 获取下一页链接
    final String continuation = getContinuation(content);
    
    return new InfoItemsPage<>(commentsItems, continuation);
}
```

**成果**:
- 为 NewPipe 增加了完整的评论交互功能
- PR 在社区获得积极反馈
- 功能已集成到主应用中

## 3. bilimiao2 - 哔哩哔哩第三方客户端

为 [bilimiao2](https://github.com/10miaomiao/bilimiao2) 贡献了多个功能优化，提升用户体验。

### PR #160: 自定义倍速菜单排序

**问题**: 用户经常使用的倍速选项排列顺序不合理，使用效率低。

**解决方案**: 
实现可自定义排序的倍速菜单，根据使用频率优化布局。

```kotlin
class SpeedMenuAdapter(
    private val context: Context,
    private val speeds: List<Float>,
    private val currentSpeed: Float,
    private val onSpeedSelected: (Float) -> Unit
) : RecyclerView.Adapter<SpeedMenuAdapter.ViewHolder>() {

    class ViewHolder(val binding: ItemSpeedMenuBinding) : 
        RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemSpeedMenuBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val speed = speeds[position]
        
        // 设置显示文本
        holder.binding.speedText.text = 
            context.getString(R.string.speed_format, speed)
        
        // 高亮当前选中的速度
        holder.binding.root.isSelected = speed == currentSpeed
        
        // 点击处理
        holder.itemView.setOnClickListener {
            onSpeedSelected(speed)
        }
    }

    override fun getItemCount() = speeds.size
}
```

### PR #18: 修复视频信息解析崩溃

**问题**: 解析视频信息失败时，由于错误处理不当导致应用崩溃。

**解决方案**:
实现更健壮的错误处理机制，确保在API返回异常数据时能够优雅降级。

```kotlin
fun parseVideoInfo(jsonData: String?): VideoInfo {
    if (jsonData.isNullOrEmpty()) {
        return VideoInfo.createErrorInfo("无数据返回")
    }
    
    return try {
        val json = JSONObject(jsonData)
        
        // 检查API错误
        val code = json.optInt("code", -1)
        if (code != 0) {
            val message = json.optString("message", "未知错误")
            return VideoInfo.createErrorInfo(message)
        }
        
        // 正常解析数据
        val data = json.optJSONObject("data")
        if (data == null) {
            return VideoInfo.createErrorInfo("数据格式错误")
        }
        
        VideoInfo(
            title = data.optString("title", ""),
            desc = data.optString("desc", ""),
            duration = data.optLong("duration", 0),
            // 其他字段...
        )
    } catch (e: Exception) {
        // 捕获所有异常，返回错误信息而非崩溃
        Log.e("VideoParser", "解析失败", e)
        VideoInfo.createErrorInfo("解析视频信息失败: ${e.message}")
    }
}
```

## 4. 其他Android生态贡献

### MatrixDev/GradleAndroidRustPlugin

多个PR改进了Android-Rust跨平台构建系统:

- **PR #14**: ✅ 已合并 (2026-02-16) - 迁移到 AGP 9.0 新 DSL API (+42/-37 行，9个文件)
- PR #11: 修复ABI交叉编译匹配逻辑
- PR #9/#10: 添加Gradle 9兼容性

#### PR #14: 迁移到 AGP 9.0 (Breaking Change)

AGP 9.0 完全移除了旧的 `BaseExtension` 类型，导致插件在配置阶段报错 `couldn't find android AppExtension or LibraryExtension`。

**核心变更**:
- 将 `AppExtension`/`LibraryExtension` (from `com.android.build.gradle`) 替换为新的 DSL 类型 (from `com.android.build.api.dsl`)
- 使用 `sdkComponents.ndkDirectory` (Provider<Directory>) 替换被移除的 `BaseExtension.ndkDirectory`
- 在 `finalizeDsl` 回调中通过 `CommonExtension` 访问 `ndkVersion`, `buildTypes` 等
- 将废弃的 `srcDir()` 替换为 `directories.add()`

**版本兼容性矩阵**:

| 插件版本 | AGP 版本 | 状态 |
|---------|---------|------|
| 0.5.0   | 7.x – 8.x | 仅维护 |
| 0.6.0   | 9.0+      | 活跃开发 |

此 PR 被 UpgradeAll 项目直接依赖，通过 JitPack fork 引入。

### Magisk相关贡献

为 topjohnwu/Magisk 贡献了简体中文翻译改进，同时为多个 Magisk 模块提供了安装功能支持。

## 🎯 总结与技能展示

### 核心Android技术能力
- 精通Android应用架构 (MVVM, Clean Architecture)
- 熟练掌握Android UI框架和自定义组件开发
- 深入理解Android权限系统和安装机制
- 掌握Gradle构建系统和NDK交叉编译

### 社区影响
- 为多个知名开源项目贡献代码
- 创建并维护有影响力的个人项目
- 积极参与社区讨论和问题解答

---

**文件版本**: v1.1  
**最后更新**: 2026-02-19

