# Wiki 贡献指南

> 如何维护和更新这个 Wiki

---

## 🎯 设计理念

这个 Wiki 的设计目标是：

1. **易于检索** - 多维度索引（年份/规模/领域）
2. **详细完整** - 包含完整的问题描述、解决方案、代码
3. **机器可读** - metadata.json 便于 AI 程序化分析
4. **持续更新** - 脚本自动化 + 人工补充

---

## 📝 更新流程

### 添加新PR

1. **确定分类**:
   ```bash
   # 项目规模
   ⭐ >30k  → by-scale/mega-projects.md
   ⭐ 10k-30k → by-scale/large-projects.md
   ⭐ 1k-10k → by-scale/medium-projects.md
   ⭐ <1k   → by-scale/small-projects.md
   
   # 年份
   2026年的PR → by-year/2026.md
   
   # 领域
   Linux内核相关 → by-domain/linux-kernel.md
   ```

2. **编写PR条目**:
   ```markdown
   ### [项目名] PR #编号 - 标题
   
   **基本信息**
   - 🔗 **PR链接**: https://...
   - ⭐ **项目Stars**: 12,000
   - 📅 **提交时间**: 2026-01-15
   - ✅ **状态**: 已合并
   - 🏷️ **标签**: `tag1` `tag2`
   - 📝 **改动**: +150 lines, 3 files
   
   **问题描述**
   [详细描述...]
   
   **解决方案**
   [技术实现...]
   
   **技术亮点**
   - 亮点1
   - 亮点2
   
   **影响评估**
   [影响分析...]
   
   **相关代码**
   \`\`\`language
   // 代码示例
   \`\`\`
   ```

3. **更新 metadata.json**:
   ```json
   {
     "projects": [
       {
         "name": "owner/repo",
         "prs": [
           {
             "number": 1234,
             "title": "...",
             "status": "merged",
             "tags": ["tag1", "tag2"]
           }
         ]
       }
     ]
   }
   ```

4. **提交变更**:
   ```bash
   git add wiki/
   git commit -m "docs(wiki): add PR #1234 for project-name"
   ```

### 修正错误

直接编辑对应的 markdown 文件，然后提交：

```bash
vim wiki/by-scale/mega-projects.md
git add wiki/by-scale/mega-projects.md
git commit -m "docs(wiki): fix typo in PR #1234"
```

### 批量更新

使用生成脚本：

```bash
cd wiki/
./generate_wiki.sh
```

---

## 🤖 AI 辅助填充

大部分占位符文件需要 AI 从 MCP Memory Service 中提取数据填充。

### 填充步骤

1. **启动 AI 助手** (OpenCode 或其他)

2. **读取指南**:
   ```
   请阅读 wiki/HOW_TO_ANALYZE.md
   ```

3. **提取数据**:
   ```
   请从你的记忆中检索"xz-dev 2025年的开源贡献"，
   并按照 wiki/by-year/2025.md 中的占位符格式，
   填充详细内容。
   ```

4. **验证质量**:
   - 确保所有链接有效
   - 确保代码示例完整
   - 确保技术描述准确

5. **提交**:
   ```bash
   git add wiki/by-year/2025.md
   git commit -m "docs(wiki): fill 2025 contributions with detailed analysis"
   ```

---

## 📊 质量标准

### 必须包含

每个PR条目必须包含：

- ✅ GitHub链接
- ✅ 项目Stars数
- ✅ 提交时间
- ✅ 当前状态
- ✅ 问题描述（至少3行）
- ✅ 解决方案概述

### 推荐包含

- 📝 技术标签
- 📝 代码改动量
- 📝 代码示例
- 📝 影响评估
- 📝 对比分析

### 避免

- ❌ 模糊描述（"修复bug" → 应详细说明bug类型）
- ❌ 无效链接
- ❌ 错误的项目信息
- ❌ 主观评价（应基于事实）

---

## 🔍 检查清单

提交前检查：

```bash
# 1. 检查markdown语法
markdownlint wiki/**/*.md

# 2. 检查链接有效性
./scripts/check-links.sh

# 3. 验证JSON格式
jq . wiki/metadata.json > /dev/null && echo "✅ JSON valid"

# 4. 统计覆盖率
./scripts/coverage.sh
```

---

## 🛠️ 工具脚本

### generate_wiki.sh

自动生成占位符文件：

```bash
./generate_wiki.sh
```

### update_stats.sh (待实现)

自动更新统计数据：

```bash
# 从GitHub API拉取最新数据
./scripts/update_stats.sh

# 更新 metadata.json
# 更新 README.md 中的统计
```

### validate.sh (待实现)

验证wiki完整性：

```bash
./scripts/validate.sh

# 检查：
# - 死链接
# - 格式错误
# - 缺失必填字段
# - 重复内容
```

---

## 📦 文件模板

### PR 条目模板

```markdown
### [项目名] PR #编号 - 标题

**基本信息**
- 🔗 **PR链接**: https://github.com/owner/repo/pull/1234
- ⭐ **项目Stars**: 12,000
- 📅 **提交时间**: 2026-01-15
- ✅ **状态**: 已合并 / 🟡 开放中 / ❌ 已关闭
- 🏷️ **标签**: `tag1` `tag2` `tag3`
- 📝 **改动**: +150/-50 lines, 3 files

**问题描述**

[背景介绍，为什么需要这个PR]

1. **场景**:
   - 描述使用场景
   - 重现步骤

2. **根本原因**:
   ```language
   // 问题代码
   ```

3. **影响范围**:
   - 影响的用户群体
   - 严重程度

**解决方案**

[技术实现细节]

```language
// 解决方案代码
```

**技术亮点**

1. **亮点1**: 描述
2. **亮点2**: 描述

**影响评估**

1. **解决的痛点**: xxx
2. **性能影响**: xxx
3. **用户影响**: xxx

**相关代码**

- 文件1: `src/path/to/file.ts:123`
- 文件2: `tests/test_file.ts:456`
```

### 年份文件模板

```markdown
# YYYY 年度贡献记录

> 本年度技术重点和主要成就

---

## 📊 年度统计

- **PR 数量**: XX 个
- **涉及项目**: XX 个
- **主要技术栈**: Python, TypeScript, ...
- **重点领域**: XXX

---

## 🎯 重点贡献

### 1. [项目名] PR #编号
[详细内容...]

### 2. [项目名] PR #编号
[详细内容...]

---

## 🔍 技术成长

本年度主要突破：
1. xxx
2. xxx

---

## 📈 统计图表

[可选：添加贡献时间线、语言分布等]
```

---

## 🤝 贡献者

欢迎贡献！提交PR或Issue到这个仓库。

- **维护者**: xz-dev
- **生成工具**: OpenCode AI + 人工整理

---

**文档版本**: v1.0  
**最后更新**: 2026-02-04
