#!/bin/bash
# Wiki 自动生成脚本
# 用途：根据存储的记忆数据，批量生成所有wiki文件

set -e

WIKI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 开始生成 Wiki 文件..."
echo "📂 工作目录: $WIKI_DIR"
echo ""

# 使用 OpenCode 调用 MCP memory 来生成内容
generate_file() {
	local file_path="$1"
	local query="$2"
	local template="$3"

	echo "📝 生成: $file_path"

	# 这里可以调用 AI 从 memory 中检索数据并生成文件
	# 暂时创建占位符
	cat >"$file_path" <<EOF
# ${template}

> 本文件由 generate_wiki.sh 自动生成
> 数据来源: MCP Memory Service
> 查询: ${query}

---

## 📊 内容概览

本部分包含 **${query}** 相关的所有贡献记录。

详细内容请使用以下命令查询：

\`\`\`bash
# 查询相关记忆
echo "请AI助手帮我检索: ${query}"

# 或使用grep搜索
grep -r "${query}" wiki/
\`\`\`

---

## 🔄 更新说明

要更新此文件，请：

1. 运行 \`./generate_wiki.sh\`
2. 或手动编辑此文件添加内容
3. 提交 git commit

---

**占位符 - 待AI从Memory Service提取数据填充**

建议内容结构：
- 时间线（如果是年份文件）
- 项目列表（如果是分类文件）
- 详细PR记录（包含问题描述、解决方案、技术亮点）
- 代码示例
- 影响评估

EOF
}

# 生成 by-year 文件
echo "📅 生成年份文件..."
for year in 2018 2019 2020 2021 2022 2023 2024 2025 2026; do
	generate_file \
		"$WIKI_DIR/by-year/$year.md" \
		"$year年的开源贡献" \
		"$year 年度贡献记录"
done

# 生成 by-scale 文件（mega-projects已手动创建）
echo "🎯 生成规模分类文件..."
generate_file \
	"$WIKI_DIR/by-scale/large-projects.md" \
	"10k-30k stars的项目" \
	"大项目贡献 (10k-30k ⭐)"

generate_file \
	"$WIKI_DIR/by-scale/medium-projects.md" \
	"1k-10k stars的项目" \
	"中等项目贡献 (1k-10k ⭐)"

generate_file \
	"$WIKI_DIR/by-scale/small-projects.md" \
	"小于1k stars的项目" \
	"小项目贡献 (<1k ⭐)"

# 生成 by-domain 文件
echo "🔬 生成技术领域文件..."
domains=(
	"linux-kernel:Linux内核与驱动"
	"windows-drivers:Windows驱动开发"
	"container-tech:容器技术"
	"ai-infrastructure:AI基础设施"
	"android:Android生态"
	"gentoo-ecosystem:Gentoo生态"
)

for domain_pair in "${domains[@]}"; do
	IFS=':' read -r domain_name domain_title <<<"$domain_pair"
	generate_file \
		"$WIKI_DIR/by-domain/$domain_name.md" \
		"$domain_title相关贡献" \
		"$domain_title"
done

# 生成 deep-dive 文件
echo "🔍 生成深度分析文件..."
generate_file \
	"$WIKI_DIR/deep-dive/mcp-servers.md" \
	"MCP Servers项目深度分析" \
	"MCP Servers - 跨进程文件锁"

generate_file \
	"$WIKI_DIR/deep-dive/virtio-gpu-driver.md" \
	"VirtIO GPU驱动深度分析" \
	"VirtIO GPU Driver - 8K分辨率支持"

generate_file \
	"$WIKI_DIR/deep-dive/distrobox-contributions.md" \
	"distrobox贡献深度分析" \
	"distrobox - cgroup委托问题"

generate_file \
	"$WIKI_DIR/deep-dive/upgradeall-project.md" \
	"UpgradeAll项目深度分析" \
	"UpgradeAll - Android更新系统"

# 生成 personal-projects 文件
echo "📦 生成个人项目文件..."
projects=(
	"distrobox-plus:distrobox-plus - Python重写distrobox"
	"numlockw:numlockw - NumLock控制工具"
	"adguardhome-logsync:AdGuardHome-LogSync - 日志同步工具"
	"kernel-autofdo-container:kernel-autofdo-container - 内核优化工具"
)

for proj_pair in "${projects[@]}"; do
	IFS=':' read -r proj_name proj_title <<<"$proj_pair"
	generate_file \
		"$WIKI_DIR/personal-projects/$proj_name.md" \
		"$proj_name项目详解" \
		"$proj_title"
done

# 生成 metadata.json
echo "📊 生成 metadata.json..."
cp /tmp/metadata_base.json "$WIKI_DIR/metadata.json"

echo ""
echo "✅ Wiki 文件生成完成！"
echo ""
echo "📈 统计："
echo "  - by-year:           $(ls -1 $WIKI_DIR/by-year/*.md 2>/dev/null | wc -l) 个文件"
echo "  - by-scale:          $(ls -1 $WIKI_DIR/by-scale/*.md 2>/dev/null | wc -l) 个文件"
echo "  - by-domain:         $(ls -1 $WIKI_DIR/by-domain/*.md 2>/dev/null | wc -l) 个文件"
echo "  - deep-dive:         $(ls -1 $WIKI_DIR/deep-dive/*.md 2>/dev/null | wc -l) 个文件"
echo "  - personal-projects: $(ls -1 $WIKI_DIR/personal-projects/*.md 2>/dev/null | wc -l) 个文件"
echo ""
echo "💡 下一步："
echo "  1. 运行 'cd wiki && ls -R' 查看所有文件"
echo "  2. 请AI助手从Memory Service提取数据填充占位符文件"
echo "  3. 运行 'git add wiki/ && git commit -m \"Add wiki documentation\"'"
echo ""
echo "🤖 AI 助手使用提示："
echo "  - 读取 HOW_TO_ANALYZE.md 了解如何分析"
echo "  - 使用 metadata.json 获取结构化数据"
echo "  - 用 grep 快速检索特定内容"
