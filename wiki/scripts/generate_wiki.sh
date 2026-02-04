#!/bin/bash

# ==================================================================
# generate_wiki.sh - Automated Wiki Content Generation
# ==================================================================
#
# Description:
#   This script automates the generation and updating of the open source
#   contribution wiki content. It pulls data from GitHub, processes it
#   and generates or updates markdown files in the wiki directory structure.
#
# Usage:
#   ./generate_wiki.sh [--update-all|--update-year YYYY|--update-domain DOMAIN]
#
# Options:
#   --update-all     Update all wiki files
#   --update-year    Update files for a specific year (e.g., 2025)
#   --update-domain  Update files for a specific domain (e.g., windows-drivers)
#   --help           Show this help message
#
# Author: xz-dev
# Created: 2026-02-04
# License: MIT
# ==================================================================

set -e

# Script configuration
WIKI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="${WIKI_ROOT}/scripts"
METADATA_FILE="${WIKI_ROOT}/metadata.json"
GITHUB_USER="xz-dev"
GITHUB_TOKEN_FILE="${HOME}/.github_token"

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
BY_YEAR_DIR="${WIKI_ROOT}/by-year"
BY_DOMAIN_DIR="${WIKI_ROOT}/by-domain"
BY_SCALE_DIR="${WIKI_ROOT}/by-scale"
DEEP_DIVE_DIR="${WIKI_ROOT}/deep-dive"
PERSONAL_PROJECTS_DIR="${WIKI_ROOT}/personal-projects"

# ==================== UTILITY FUNCTIONS ====================

# Print with color and timestamp
log() {
	local level=$1
	local message=$2
	local color=$NC
	local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

	case $level in
	"INFO") color=$GREEN ;;
	"WARN") color=$YELLOW ;;
	"ERROR") color=$RED ;;
	"STEP") color=$BLUE ;;
	esac

	echo -e "${timestamp} ${color}[${level}]${NC} ${message}"
}

# Check required dependencies
check_dependencies() {
	log "STEP" "Checking dependencies..."

	local missing_deps=()

	for cmd in jq curl git grep sed awk; do
		if ! command -v $cmd &>/dev/null; then
			missing_deps+=($cmd)
		fi
	done

	if [ ${#missing_deps[@]} -ne 0 ]; then
		log "ERROR" "Missing required dependencies: ${missing_deps[*]}"
		log "ERROR" "Please install them and try again."
		exit 1
	fi

	log "INFO" "All dependencies are installed."
}

# Check if GitHub token exists
check_github_token() {
	if [ ! -f "$GITHUB_TOKEN_FILE" ]; then
		log "ERROR" "GitHub token file not found at $GITHUB_TOKEN_FILE"
		log "ERROR" "Create a file with your GitHub token at $GITHUB_TOKEN_FILE"
		exit 1
	fi

	GITHUB_TOKEN=$(cat "$GITHUB_TOKEN_FILE")

	# Validate token
	local response
	response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
		"https://api.github.com/user")

	if [ "$response" != "200" ]; then
		log "ERROR" "Invalid GitHub token. HTTP response: $response"
		exit 1
	fi

	log "INFO" "GitHub token validated successfully."
}

# Create directories if they don't exist
ensure_directories() {
	log "STEP" "Ensuring directories exist..."

	for dir in "$BY_YEAR_DIR" "$BY_DOMAIN_DIR" "$BY_SCALE_DIR" "$DEEP_DIVE_DIR" "$PERSONAL_PROJECTS_DIR" "$SCRIPTS_DIR"; do
		if [ ! -d "$dir" ]; then
			log "INFO" "Creating directory: $dir"
			mkdir -p "$dir"
		fi
	done
}

# Fetch GitHub user information
fetch_user_info() {
	log "STEP" "Fetching user information for $GITHUB_USER..."

	local response
	response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
		"https://api.github.com/users/$GITHUB_USER")

	local name
	local public_repos
	name=$(echo "$response" | jq -r '.name // "Unknown"')
	public_repos=$(echo "$response" | jq -r '.public_repos // 0')

	log "INFO" "Found user: $name with $public_repos public repositories"

	echo "$response" >"${SCRIPTS_DIR}/user_info.json"
}

# Fetch all repositories for the user
fetch_repositories() {
	log "STEP" "Fetching repositories for $GITHUB_USER..."

	local page=1
	local per_page=100
	local all_repos="[]"

	while true; do
		log "INFO" "Fetching page $page..."
		local response
		response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
			"https://api.github.com/users/$GITHUB_USER/repos?page=$page&per_page=$per_page&sort=updated")

		local repos_count
		repos_count=$(echo "$response" | jq length)

		if [ "$repos_count" -eq 0 ]; then
			break
		fi

		all_repos=$(echo "$all_repos" "$response" | jq -s '.[0] + .[1]')

		page=$((page + 1))

		# Respect GitHub's rate limiting
		sleep 1
	done

	echo "$all_repos" >"${SCRIPTS_DIR}/repositories.json"
	log "INFO" "Fetched $(echo "$all_repos" | jq length) repositories."
}

# Fetch pull requests created by the user
fetch_pull_requests() {
	log "STEP" "Fetching pull requests created by $GITHUB_USER..."

	local search_query="author:$GITHUB_USER type:pr"
	local page=1
	local per_page=100
	local all_prs="[]"

	while true; do
		log "INFO" "Fetching page $page..."
		local response
		response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
			"https://api.github.com/search/issues?q=$search_query&page=$page&per_page=$per_page&sort=updated")

		local items
		items=$(echo "$response" | jq '.items')
		local items_count
		items_count=$(echo "$items" | jq length)

		if [ "$items_count" -eq 0 ]; then
			break
		fi

		all_prs=$(echo "$all_prs" "$items" | jq -s '.[0] + .[1]')

		local total_count
		total_count=$(echo "$response" | jq '.total_count')

		log "INFO" "Progress: $(echo "$all_prs" | jq length)/$total_count"

		page=$((page + 1))

		# Respect GitHub's rate limiting
		sleep 2
	done

	echo "$all_prs" >"${SCRIPTS_DIR}/pull_requests.json"
	log "INFO" "Fetched $(echo "$all_prs" | jq length) pull requests."
}

# Fetch detailed information for each PR
enrich_pull_requests() {
	log "STEP" "Enriching pull request data..."

	local pull_requests
	pull_requests=$(cat "${SCRIPTS_DIR}/pull_requests.json")
	local pr_count
	pr_count=$(echo "$pull_requests" | jq length)
	local enriched_prs="[]"

	local i=0
	while [ $i -lt "$pr_count" ]; do
		local pr
		pr=$(echo "$pull_requests" | jq ".[$i]")
		local repo_url
		repo_url=$(echo "$pr" | jq -r '.repository_url')
		local pr_number
		pr_number=$(echo "$pr" | jq -r '.number')
		local pr_url
		pr_url=$(echo "$pr" | jq -r '.pull_request.url')

		log "INFO" "Enriching PR #$pr_number ($(($i + 1))/$pr_count)..."

		# Get repository information
		local repo_response
		repo_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$repo_url")
		local repo_stars
		repo_stars=$(echo "$repo_response" | jq '.stargazers_count')
		local repo_full_name
		repo_full_name=$(echo "$repo_response" | jq -r '.full_name')

		# Get PR details
		local pr_detail_response
		pr_detail_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$pr_url")
		local pr_merged
		pr_merged=$(echo "$pr_detail_response" | jq '.merged')
		local pr_state
		pr_state=$(echo "$pr_detail_response" | jq -r '.state')
		local pr_merged_at
		pr_merged_at=$(echo "$pr_detail_response" | jq '.merged_at')
		local pr_additions
		pr_additions=$(echo "$pr_detail_response" | jq '.additions // 0')
		local pr_deletions
		pr_deletions=$(echo "$pr_detail_response" | jq '.deletions // 0')
		local pr_changed_files
		pr_changed_files=$(echo "$pr_detail_response" | jq '.changed_files // 0')

		# Classify PR
		local pr_scale
		if [ "$repo_stars" -gt 30000 ]; then
			pr_scale="mega"
		elif [ "$repo_stars" -gt 10000 ]; then
			pr_scale="large"
		elif [ "$repo_stars" -gt 1000 ]; then
			pr_scale="medium"
		else
			pr_scale="small"
		fi

		# Determine PR status
		local pr_status
		if [ "$pr_merged" = "true" ]; then
			pr_status="merged"
		elif [ "$pr_state" = "open" ]; then
			pr_status="open"
		else
			pr_status="closed"
		fi

		# Extract year from created_at
		local pr_created_at
		pr_created_at=$(echo "$pr" | jq -r '.created_at')
		local pr_year
		pr_year=$(echo "$pr_created_at" | cut -d'-' -f1)

		# Guess the domain based on repository name and description
		local repo_description
		repo_description=$(echo "$repo_response" | jq -r '.description')
		local pr_domain="other"

		if echo "$repo_full_name $repo_description" | grep -i -E 'linux|kernel|scheduler' >/dev/null; then
			pr_domain="linux-kernel"
		elif echo "$repo_full_name $repo_description" | grep -i -E 'windows|virtio|driver' >/dev/null; then
			pr_domain="windows-drivers"
		elif echo "$repo_full_name $repo_description" | grep -i -E 'container|podman|docker|distrobox' >/dev/null; then
			pr_domain="container-tech"
		elif echo "$repo_full_name $repo_description" | grep -i -E 'ai|mcp|llm|claude|assistant|context' >/dev/null; then
			pr_domain="ai-infrastructure"
		elif echo "$repo_full_name $repo_description" | grep -i -E 'android|kotlin|mobile|app' >/dev/null; then
			pr_domain="android"
		elif echo "$repo_full_name $repo_description" | grep -i -E 'gentoo|ebuild|portage|openrc' >/dev/null; then
			pr_domain="gentoo-ecosystem"
		fi

		# Combine all information
		local enriched_pr
		enriched_pr=$(echo "$pr" | jq --arg repo_full_name "$repo_full_name" \
			--arg repo_stars "$repo_stars" \
			--arg pr_scale "$pr_scale" \
			--arg pr_status "$pr_status" \
			--arg pr_year "$pr_year" \
			--arg pr_domain "$pr_domain" \
			--arg pr_additions "$pr_additions" \
			--arg pr_deletions "$pr_deletions" \
			--arg pr_changed_files "$pr_changed_files" \
			--arg pr_merged_at "$pr_merged_at" \
			'. + {
        repo_full_name: $repo_full_name,
        repo_stars: $repo_stars | tonumber,
        scale: $pr_scale,
        status: $pr_status,
        year: $pr_year,
        domain: $pr_domain,
        additions: $pr_additions | tonumber,
        deletions: $pr_deletions | tonumber,
        changed_files: $pr_changed_files | tonumber,
        merged_at: $pr_merged_at
      }')

		enriched_prs=$(echo "$enriched_prs" "$enriched_pr" | jq -s '.[0] + [.[1]]')

		i=$((i + 1))

		# Respect GitHub's rate limiting
		sleep 2
	done

	echo "$enriched_prs" >"${SCRIPTS_DIR}/enriched_prs.json"
	log "INFO" "Enriched $(echo "$enriched_prs" | jq length) pull requests."
}

# Generate metadata.json from the enriched PRs
generate_metadata() {
	log "STEP" "Generating metadata.json..."

	local enriched_prs
	enriched_prs=$(cat "${SCRIPTS_DIR}/enriched_prs.json")

	# Calculate statistics
	local total_prs
	total_prs=$(echo "$enriched_prs" | jq length)

	# Get date range
	local min_date
	min_date=$(echo "$enriched_prs" | jq -r '[.[].created_at] | min')
	local max_date
	max_date=$(echo "$enriched_prs" | jq -r '[.[].created_at] | max')
	local min_year
	min_year=$(echo "$min_date" | cut -d'-' -f1)
	local max_year
	max_year=$(echo "$max_date" | cut -d'-' -f1)

	# Count by scale
	local mega_count
	mega_count=$(echo "$enriched_prs" | jq '[.[] | select(.scale=="mega")] | length')
	local large_count
	large_count=$(echo "$enriched_prs" | jq '[.[] | select(.scale=="large")] | length')
	local medium_count
	medium_count=$(echo "$enriched_prs" | jq '[.[] | select(.scale=="medium")] | length')
	local small_count
	small_count=$(echo "$enriched_prs" | jq '[.[] | select(.scale=="small")] | length')

	# Count by status
	local merged_count
	merged_count=$(echo "$enriched_prs" | jq '[.[] | select(.status=="merged")] | length')
	local open_count
	open_count=$(echo "$enriched_prs" | jq '[.[] | select(.status=="open")] | length')
	local closed_count
	closed_count=$(echo "$enriched_prs" | jq '[.[] | select(.status=="closed")] | length')

	# Count by domain
	local linux_kernel_count
	linux_kernel_count=$(echo "$enriched_prs" | jq '[.[] | select(.domain=="linux-kernel")] | length')
	local windows_drivers_count
	windows_drivers_count=$(echo "$enriched_prs" | jq '[.[] | select(.domain=="windows-drivers")] | length')
	local container_tech_count
	container_tech_count=$(echo "$enriched_prs" | jq '[.[] | select(.domain=="container-tech")] | length')
	local ai_infrastructure_count
	ai_infrastructure_count=$(echo "$enriched_prs" | jq '[.[] | select(.domain=="ai-infrastructure")] | length')
	local android_count
	android_count=$(echo "$enriched_prs" | jq '[.[] | select(.domain=="android")] | length')
	local gentoo_ecosystem_count
	gentoo_ecosystem_count=$(echo "$enriched_prs" | jq '[.[] | select(.domain=="gentoo-ecosystem")] | length')

	# Count by language (estimate based on repo name and file extensions)
	# This is an approximation - would need to analyze PR files for accuracy
	local python_count=0
	local shell_count=0
	local kotlin_count=0
	local typescript_count=0
	local cpp_count=0
	local rust_count=0
	local other_count=0

	for lang in python shell kotlin typescript cpp rust; do
		local count
		count=$(echo "$enriched_prs" | jq --arg lang "$lang" '[.[] | select(.body | ascii_downcase | contains($lang) or .title | ascii_downcase | contains($lang) or .repo_full_name | ascii_downcase | contains($lang))] | length')

		case $lang in
		"python") python_count=$count ;;
		"shell") shell_count=$count ;;
		"kotlin") kotlin_count=$count ;;
		"typescript") typescript_count=$count ;;
		"cpp") cpp_count=$count ;;
		"rust") rust_count=$count ;;
		esac
	done

	# Approximate 'other' count - this won't be precise
	other_count=$((total_prs - python_count - shell_count - kotlin_count - typescript_count - cpp_count - rust_count))
	# Ensure it's not negative
	if [ $other_count -lt 0 ]; then
		other_count=0
	fi

	# Count by year
	local year_counts="{}"
	for year in $(seq $min_year $max_year); do
		local year_count
		year_count=$(echo "$enriched_prs" | jq --arg year "$year" '[.[] | select(.year==$year)] | length')
		year_counts=$(echo "$year_counts" | jq --arg year "$year" --arg count "$year_count" '. + {($year): ($count | tonumber)}')
	done

	# Generate the metadata JSON
	local metadata
	metadata=$(jq -n \
		--arg version "1.0" \
		--arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
		--arg author "$GITHUB_USER" \
		--arg github_url "https://github.com/$GITHUB_USER" \
		--arg total_prs "$total_prs" \
		--arg min_date "$min_date" \
		--arg max_date "$max_date" \
		--arg mega_count "$mega_count" \
		--arg large_count "$large_count" \
		--arg medium_count "$medium_count" \
		--arg small_count "$small_count" \
		--arg merged_count "$merged_count" \
		--arg open_count "$open_count" \
		--arg closed_count "$closed_count" \
		--arg python_count "$python_count" \
		--arg shell_count "$shell_count" \
		--arg kotlin_count "$kotlin_count" \
		--arg typescript_count "$typescript_count" \
		--arg cpp_count "$cpp_count" \
		--arg rust_count "$rust_count" \
		--arg other_count "$other_count" \
		--arg linux_kernel_count "$linux_kernel_count" \
		--arg windows_drivers_count "$windows_drivers_count" \
		--arg container_tech_count "$container_tech_count" \
		--arg ai_infrastructure_count "$ai_infrastructure_count" \
		--arg android_count "$android_count" \
		--arg gentoo_ecosystem_count "$gentoo_ecosystem_count" \
		--argjson year_counts "$year_counts" \
		'{
      "version": $version,
      "generated_at": $generated_at,
      "author": $author,
      "github_url": $github_url,
      "total_prs": ($total_prs | tonumber),
      "date_range": {
        "start": $min_date,
        "end": $max_date
      },
      "statistics": {
        "by_scale": {
          "mega": ($mega_count | tonumber),
          "large": ($large_count | tonumber),
          "medium": ($medium_count | tonumber),
          "small": ($small_count | tonumber)
        },
        "by_status": {
          "merged": ($merged_count | tonumber),
          "open": ($open_count | tonumber),
          "closed": ($closed_count | tonumber)
        },
        "by_language": {
          "Python": ($python_count | tonumber),
          "Shell": ($shell_count | tonumber),
          "Kotlin": ($kotlin_count | tonumber),
          "TypeScript": ($typescript_count | tonumber),
          "C/C++": ($cpp_count | tonumber),
          "Rust": ($rust_count | tonumber),
          "Other": ($other_count | tonumber)
        },
        "by_domain": {
          "linux-kernel": ($linux_kernel_count | tonumber),
          "windows-drivers": ($windows_drivers_count | tonumber),
          "container-tech": ($container_tech_count | tonumber),
          "ai-infrastructure": ($ai_infrastructure_count | tonumber),
          "android": ($android_count | tonumber),
          "gentoo-ecosystem": ($gentoo_ecosystem_count | tonumber)
        },
        "by_year": $year_counts
      }
    }')

	echo "$metadata" >"$METADATA_FILE"
	log "INFO" "Generated metadata.json"
}

# Format a PR for markdown
format_pr_markdown() {
	local pr=$1

	local title
	title=$(echo "$pr" | jq -r '.title')
	local number
	number=$(echo "$pr" | jq -r '.number')
	local repo
	repo=$(echo "$pr" | jq -r '.repo_full_name')
	local html_url
	html_url=$(echo "$pr" | jq -r '.html_url')
	local stars
	stars=$(echo "$pr" | jq -r '.repo_stars')
	local created_at
	created_at=$(echo "$pr" | jq -r '.created_at' | cut -d'T' -f1)
	local status
	status=$(echo "$pr" | jq -r '.status')

	# Determine status emoji
	local status_emoji
	if [ "$status" = "merged" ]; then
		status_emoji="✅"
	elif [ "$status" = "open" ]; then
		status_emoji="🟡"
	else
		status_emoji="❌"
	fi

	# Generate short description (use PR body or generate one)
	local body
	body=$(echo "$pr" | jq -r '.body // ""')
	local description
	if [ -z "$body" ] || [ "$body" = "null" ]; then
		description="$(echo "$title" | sed 's/^[A-Za-z]\+: //g')"
	else
		# Extract first paragraph or first line if it's short
		description=$(echo "$body" | grep -v "^#" | grep -v "^$" | head -n 1)
		# Limit length
		description=$(echo "$description" | cut -c 1-150)
		if [ ${#description} -eq 150 ]; then
			description="${description}..."
		fi
	fi

	# Generate Markdown
	cat <<EOF
- [$repo] PR #$number - $title ($created_at)
  - 🔗 [PR Link]($html_url)
  - ⭐ $stars stars
  - $status_emoji $status
  - $description

EOF
}

# Generate yearly markdown files
generate_year_files() {
	log "STEP" "Generating yearly markdown files..."

	local enriched_prs
	enriched_prs=$(cat "${SCRIPTS_DIR}/enriched_prs.json")
	local metadata
	metadata=$(cat "$METADATA_FILE")

	# Get year range
	local min_year
	min_year=$(echo "$metadata" | jq '.date_range.start' | cut -d'-' -f1 | sed 's/"//g')
	local max_year
	max_year=$(echo "$metadata" | jq '.date_range.end' | cut -d'-' -f1 | sed 's/"//g')

	for year in $(seq $min_year $max_year); do
		local year_file="${BY_YEAR_DIR}/${year}.md"
		local year_count
		year_count=$(echo "$metadata" | jq ".statistics.by_year[\"$year\"]")

		# Skip years with no contributions
		if [ "$year_count" -eq 0 ]; then
			continue
		fi

		log "INFO" "Generating file for year $year ($year_count PRs)..."

		# Generate header
		cat >"$year_file" <<EOF
# ${year} 年度贡献记录

> **生成时间**: $(date +"%Y-%m-%d")  
> **贡献总数**: ${year_count}个 PR  
> **数据来源**: GitHub API + 人工整理

---

## 📊 年度概览

EOF

		# Generate stats for this year
		local year_prs
		year_prs=$(echo "$enriched_prs" | jq --arg year "$year" '[.[] | select(.year==$year)]')

		# Count by status
		local merged_count
		merged_count=$(echo "$year_prs" | jq '[.[] | select(.status=="merged")] | length')
		local open_count
		open_count=$(echo "$year_prs" | jq '[.[] | select(.status=="open")] | length')
		local closed_count
		closed_count=$(echo "$year_prs" | jq '[.[] | select(.status=="closed")] | length')
		local merge_rate
		merge_rate=$(awk "BEGIN {printf \"%.1f\", 100 * $merged_count / $year_count}")

		# Count by scale
		local mega_count
		mega_count=$(echo "$year_prs" | jq '[.[] | select(.scale=="mega")] | length')
		local large_count
		large_count=$(echo "$year_prs" | jq '[.[] | select(.scale=="large")] | length')
		local medium_count
		medium_count=$(echo "$year_prs" | jq '[.[] | select(.scale=="medium")] | length')
		local small_count
		small_count=$(echo "$year_prs" | jq '[.[] | select(.scale=="small")] | length')

		# Count by domain
		local domain_counts="{}"
		for domain in "linux-kernel" "windows-drivers" "container-tech" "ai-infrastructure" "android" "gentoo-ecosystem"; do
			local count
			count=$(echo "$year_prs" | jq --arg domain "$domain" '[.[] | select(.domain==$domain)] | length')
			domain_counts=$(echo "$domain_counts" | jq --arg domain "$domain" --arg count "$count" '. + {($domain): ($count | tonumber)}')
		done

		# Calculate code changes
		local total_additions
		total_additions=$(echo "$year_prs" | jq '[.[] | .additions] | add')
		local total_deletions
		total_deletions=$(echo "$year_prs" | jq '[.[] | .deletions] | add')
		local total_changed_files
		total_changed_files=$(echo "$year_prs" | jq '[.[] | .changed_files] | add')

		# Calculate top repositories
		local top_repos
		top_repos=$(echo "$year_prs" | jq 'group_by(.repo_full_name) | map({repo: .[0].repo_full_name, count: length}) | sort_by(-.count) | .[0:5]')

		# Add statistics to file
		cat >>"$year_file" <<EOF
### 核心数据

- **PR总数**: ${year_count}个
- **合并率**: ${merge_rate}% (${merged_count}已合并, ${open_count}开放中, ${closed_count}已关闭)
- **代码变更**: +${total_additions}行, -${total_deletions}行, 变更${total_changed_files}个文件
- **项目规模**:
  - 超大项目 (>30k ⭐): ${mega_count}个
  - 大项目 (10k-30k ⭐): ${large_count}个
  - 中等项目 (1k-10k ⭐): ${medium_count}个
  - 小项目 (<1k ⭐): ${small_count}个

### 主要贡献仓库

EOF

		# Add top repos
		local repo_index=0
		while [ $repo_index -lt $(echo "$top_repos" | jq 'length') ]; do
			local repo
			repo=$(echo "$top_repos" | jq -r ".[$repo_index].repo")
			local count
			count=$(echo "$top_repos" | jq -r ".[$repo_index].count")
			echo "- **${repo}**: ${count}个PR" >>"$year_file"
			repo_index=$((repo_index + 1))
		done

		# Add domain distribution
		cat >>"$year_file" <<EOF

### 技术领域分布

\`\`\`
EOF

		# Calculate percentages for domain distribution
		for domain in "linux-kernel" "windows-drivers" "container-tech" "ai-infrastructure" "android" "gentoo-ecosystem"; do
			local count
			count=$(echo "$domain_counts" | jq ".[\"$domain\"]")
			local percent
			percent=$(awk "BEGIN {printf \"%.0f\", 100 * $count / $year_count}")

			local domain_name
			case $domain in
			"linux-kernel") domain_name="Linux内核/驱动" ;;
			"windows-drivers") domain_name="Windows驱动" ;;
			"container-tech") domain_name="容器技术   " ;;
			"ai-infrastructure") domain_name="AI基础设施 " ;;
			"android") domain_name="Android开发" ;;
			"gentoo-ecosystem") domain_name="Gentoo生态 " ;;
			esac

			# Create ASCII graph
			local bar=""
			local bar_length=$((percent / 5))
			for ((j = 0; j < bar_length; j++)); do
				bar="${bar}█"
			done
			for ((j = bar_length; j < 20; j++)); do
				bar="${bar}░"
			done

			echo "${domain_name}    ${bar} ${percent}%" >>"$year_file"
		done

		cat >>"$year_file" <<EOF
\`\`\`

---

## 🗓️ 贡献时间线

EOF

		# Group PRs by quarter
		local quarters=("Q1 (1月-3月)" "Q2 (4月-6月)" "Q3 (7月-9月)" "Q4 (10月-12月)")
		for q in "${!quarters[@]}"; do
			local quarter=${quarters[$q]}
			local start_month=$((q * 3 + 1))
			local end_month=$((q * 3 + 3))

			# Filter PRs for this quarter
			local quarter_prs
			quarter_prs=$(echo "$year_prs" | jq --arg year "$year" --arg start_month "$(printf %02d $start_month)" --arg end_month "$(printf %02d $end_month)" '[.[] | select(.created_at | startswith($year + "-" + $start_month) or startswith($year + "-" + ($start_month | tonumber + 1 | tostring)) or startswith($year + "-" + $end_month))]')

			local quarter_count
			quarter_count=$(echo "$quarter_prs" | jq 'length')

			if [ "$quarter_count" -eq 0 ]; then
				continue
			fi

			# Add quarter header
			cat >>"$year_file" <<EOF
### ${quarter} - ${quarter_count}个PR

EOF

			# Group by month
			for month in $(seq $start_month $end_month); do
				local month_prs
				month_prs=$(echo "$year_prs" | jq --arg year "$year" --arg month "$(printf %02d $month)" '[.[] | select(.created_at | startswith($year + "-" + $month))]')

				local month_count
				month_count=$(echo "$month_prs" | jq 'length')

				if [ "$month_count" -eq 0 ]; then
					continue
				fi

				# Get month name
				local month_name
				case $month in
				1) month_name="1月" ;;
				2) month_name="2月" ;;
				3) month_name="3月" ;;
				4) month_name="4月" ;;
				5) month_name="5月" ;;
				6) month_name="6月" ;;
				7) month_name="7月" ;;
				8) month_name="8月" ;;
				9) month_name="9月" ;;
				10) month_name="10月" ;;
				11) month_name="11月" ;;
				12) month_name="12月" ;;
				esac

				# Add month header
				cat >>"$year_file" <<EOF
#### ⭐ ${month_name} - ${month_count}个PR

EOF

				# Sort PRs by date
				local sorted_month_prs
				sorted_month_prs=$(echo "$month_prs" | jq 'sort_by(.created_at)')

				# Add each PR
				local pr_index=0
				while [ $pr_index -lt $(echo "$sorted_month_prs" | jq 'length') ]; do
					local pr
					pr=$(echo "$sorted_month_prs" | jq ".[$pr_index]")

					format_pr_markdown "$pr" >>"$year_file"

					pr_index=$((pr_index + 1))
				done
			done
		done

		cat >>"$year_file" <<EOF
---

## 🔍 主要技术成就

### 技术成长

${year}年代表了以下方向的成长：

1. **待填充**: 此部分需要手动编辑，添加${year}年的主要技术进步
2. **待填充**: 此部分需要手动编辑，添加${year}年的代表性项目
3. **待填充**: 此部分需要手动编辑，添加${year}年的技术亮点

### 影响力项目

- **待填充**: 此部分需要手动编辑，添加${year}年的高影响力项目

---

**文件版本**: v1.0  
**最后更新**: $(date +"%Y-%m-%d")  
**生成工具**: generate_wiki.sh
EOF

		log "INFO" "Generated ${year}.md"
	done
}

# Generate domain files
generate_domain_files() {
	log "STEP" "Generating domain markdown files..."

	local enriched_prs
	enriched_prs=$(cat "${SCRIPTS_DIR}/enriched_prs.json")

	local domains=("linux-kernel" "windows-drivers" "container-tech" "ai-infrastructure" "android" "gentoo-ecosystem")
	local domain_titles=("Linux内核与驱动" "Windows驱动开发" "容器技术" "AI基础设施" "Android生态" "Gentoo生态")

	for i in "${!domains[@]}"; do
		local domain=${domains[$i]}
		local title=${domain_titles[$i]}
		local domain_file="${BY_DOMAIN_DIR}/${domain}.md"

		# Filter PRs for this domain
		local domain_prs
		domain_prs=$(echo "$enriched_prs" | jq --arg domain "$domain" '[.[] | select(.domain==$domain)]')

		local domain_count
		domain_count=$(echo "$domain_prs" | jq 'length')

		if [ "$domain_count" -eq 0 ]; then
			continue
		fi

		log "INFO" "Generating file for domain $domain ($domain_count PRs)..."

		# Generate header
		cat >"$domain_file" <<EOF
# ${title}

> **生成时间**: $(date +"%Y-%m-%d")  
> **贡献总数**: ${domain_count}个 PR  
> **数据来源**: GitHub API + 人工整理

---

## 📊 领域概览

EOF

		# Generate stats for this domain

		# Count by status
		local merged_count
		merged_count=$(echo "$domain_prs" | jq '[.[] | select(.status=="merged")] | length')
		local open_count
		open_count=$(echo "$domain_prs" | jq '[.[] | select(.status=="open")] | length')
		local closed_count
		closed_count=$(echo "$domain_prs" | jq '[.[] | select(.status=="closed")] | length')
		local merge_rate
		merge_rate=$(awk "BEGIN {printf \"%.1f\", 100 * $merged_count / $domain_count}")

		# Count by scale
		local mega_count
		mega_count=$(echo "$domain_prs" | jq '[.[] | select(.scale=="mega")] | length')
		local large_count
		large_count=$(echo "$domain_prs" | jq '[.[] | select(.scale=="large")] | length')
		local medium_count
		medium_count=$(echo "$domain_prs" | jq '[.[] | select(.scale=="medium")] | length')
		local small_count
		small_count=$(echo "$domain_prs" | jq '[.[] | select(.scale=="small")] | length')

		# Count by year
		local year_counts="{}"
		for year in $(seq 2017 2026); do
			local count
			count=$(echo "$domain_prs" | jq --arg year "$year" '[.[] | select(.year==$year)] | length')
			year_counts=$(echo "$year_counts" | jq --arg year "$year" --arg count "$count" '. + {($year): ($count | tonumber)}')
		done

		# Calculate code changes
		local total_additions
		total_additions=$(echo "$domain_prs" | jq '[.[] | .additions] | add')
		local total_deletions
		total_deletions=$(echo "$domain_prs" | jq '[.[] | .deletions] | add')
		local total_changed_files
		total_changed_files=$(echo "$domain_prs" | jq '[.[] | .changed_files] | add')

		# Calculate top repositories
		local top_repos
		top_repos=$(echo "$domain_prs" | jq 'group_by(.repo_full_name) | map({repo: .[0].repo_full_name, count: length}) | sort_by(-.count) | .[0:5]')

		# Add statistics to file
		cat >>"$domain_file" <<EOF
### 核心数据

- **PR总数**: ${domain_count}个
- **合并率**: ${merge_rate}% (${merged_count}已合并, ${open_count}开放中, ${closed_count}已关闭)
- **代码变更**: +${total_additions}行, -${total_deletions}行, 变更${total_changed_files}个文件
- **项目规模**:
  - 超大项目 (>30k ⭐): ${mega_count}个
  - 大项目 (10k-30k ⭐): ${large_count}个
  - 中等项目 (1k-10k ⭐): ${medium_count}个
  - 小项目 (<1k ⭐): ${small_count}个

### 主要贡献仓库

EOF

		# Add top repos
		local repo_index=0
		while [ $repo_index -lt $(echo "$top_repos" | jq 'length') ]; do
			local repo
			repo=$(echo "$top_repos" | jq -r ".[$repo_index].repo")
			local count
			count=$(echo "$top_repos" | jq -r ".[$repo_index].count")
			echo "- **${repo}**: ${count}个PR" >>"$domain_file"
			repo_index=$((repo_index + 1))
		done

		# Add year distribution
		cat >>"$domain_file" <<EOF

### 贡献时间分布

\`\`\`
EOF

		# Calculate percentages for year distribution
		for year in $(seq 2017 2026); do
			local count
			count=$(echo "$year_counts" | jq ".[\"$year\"]")

			if [ "$count" -eq 0 ]; then
				continue
			fi

			local percent
			percent=$(awk "BEGIN {printf \"%.0f\", 100 * $count / $domain_count}")

			# Create ASCII graph
			local bar=""
			local bar_length=$((percent / 5))
			for ((j = 0; j < bar_length; j++)); do
				bar="${bar}█"
			done
			for ((j = bar_length; j < 20; j++)); do
				bar="${bar}░"
			done

			echo "${year}年    ${bar} ${percent}% (${count}个PR)" >>"$domain_file"
		done

		cat >>"$domain_file" <<EOF
\`\`\`

---

## 🔍 代表性项目

EOF

		# Sort PRs by stars and take top 10
		local top_prs
		top_prs=$(echo "$domain_prs" | jq 'sort_by(-.repo_stars) | .[0:10]')

		# Add each top PR
		local pr_index=0
		while [ $pr_index -lt $(echo "$top_prs" | jq 'length') ]; do
			local pr
			pr=$(echo "$top_prs" | jq ".[$pr_index]")

			local title
			title=$(echo "$pr" | jq -r '.title')
			local number
			number=$(echo "$pr" | jq -r '.number')
			local repo
			repo=$(echo "$pr" | jq -r '.repo_full_name')
			local html_url
			html_url=$(echo "$pr" | jq -r '.html_url')
			local stars
			stars=$(echo "$pr" | jq -r '.repo_stars')
			local created_at
			created_at=$(echo "$pr" | jq -r '.created_at' | cut -d'T' -f1)
			local status
			status=$(echo "$pr" | jq -r '.status')

			# Determine status emoji
			local status_emoji
			if [ "$status" = "merged" ]; then
				status_emoji="✅"
			elif [ "$status" = "open" ]; then
				status_emoji="🟡"
			else
				status_emoji="❌"
			fi

			cat >>"$domain_file" <<EOF
### [${repo}] PR #${number} - ${title}

**基本信息**
- 🔗 **PR链接**: ${html_url}
- ⭐ **项目Stars**: ${stars}
- 📅 **提交时间**: ${created_at}
- ${status_emoji} **状态**: ${status}

**详情**
待填充 - 此部分需要手动编辑，添加PR的详细信息

EOF

			pr_index=$((pr_index + 1))
		done

		cat >>"$domain_file" <<EOF
---

## 🎯 技术亮点

### 关键技术能力

- **待填充**: 此部分需要手动编辑，添加在${title}领域的关键技术能力
- **待填充**: 此部分需要手动编辑，添加在${title}领域的技术深度
- **待填充**: 此部分需要手动编辑，添加在${title}领域的独特贡献

### 影响力分析

- **待填充**: 此部分需要手动编辑，添加${title}贡献的影响力分析

---

## 🔗 相关资源

- **待填充**: 此部分需要手动编辑，添加相关资源链接

---

**文件版本**: v1.0  
**最后更新**: $(date +"%Y-%m-%d")  
**生成工具**: generate_wiki.sh
EOF

		log "INFO" "Generated ${domain}.md"
	done
}

# Generate scale-based files
generate_scale_files() {
	log "STEP" "Generating scale-based markdown files..."

	local enriched_prs
	enriched_prs=$(cat "${SCRIPTS_DIR}/enriched_prs.json")

	local scales=("mega" "large" "medium" "small")
	local scale_titles=("超大项目贡献 (>30k ⭐)" "大项目贡献 (10k-30k ⭐)" "中等项目贡献 (1k-10k ⭐)" "小项目贡献 (<1k ⭐)")

	for i in "${!scales[@]}"; do
		local scale=${scales[$i]}
		local title=${scale_titles[$i]}
		local scale_file="${BY_SCALE_DIR}/${scale}-projects.md"

		# Filter PRs for this scale
		local scale_prs
		scale_prs=$(echo "$enriched_prs" | jq --arg scale "$scale" '[.[] | select(.scale==$scale)]')

		local scale_count
		scale_count=$(echo "$scale_prs" | jq 'length')

		if [ "$scale_count" -eq 0 ]; then
			continue
		fi

		log "INFO" "Generating file for scale $scale ($scale_count PRs)..."

		# Generate header
		cat >"$scale_file" <<EOF
# ${title}

> **生成时间**: $(date +"%Y-%m-%d")  
> **贡献总数**: ${scale_count}个 PR  
> **数据来源**: GitHub API + 人工整理

---

## 📊 规模概览

EOF

		# Generate stats for this scale

		# Count by status
		local merged_count
		merged_count=$(echo "$scale_prs" | jq '[.[] | select(.status=="merged")] | length')
		local open_count
		open_count=$(echo "$scale_prs" | jq '[.[] | select(.status=="open")] | length')
		local closed_count
		closed_count=$(echo "$scale_prs" | jq '[.[] | select(.status=="closed")] | length')
		local merge_rate
		merge_rate=$(awk "BEGIN {printf \"%.1f\", 100 * $merged_count / $scale_count}")

		# Count unique repositories
		local repos_count
		repos_count=$(echo "$scale_prs" | jq '[.[] | .repo_full_name] | unique | length')

		# Calculate total stars
		local total_stars
		total_stars=$(echo "$scale_prs" | jq '[.[] | .repo_stars] | unique | add')

		# Count by domain
		local domain_counts="{}"
		for domain in "linux-kernel" "windows-drivers" "container-tech" "ai-infrastructure" "android" "gentoo-ecosystem"; do
			local count
			count=$(echo "$scale_prs" | jq --arg domain "$domain" '[.[] | select(.domain==$domain)] | length')
			domain_counts=$(echo "$domain_counts" | jq --arg domain "$domain" --arg count "$count" '. + {($domain): ($count | tonumber)}')
		done

		# Get top repositories
		local top_repos
		top_repos=$(echo "$scale_prs" | jq 'group_by(.repo_full_name) | map({repo: .[0].repo_full_name, stars: .[0].repo_stars, count: length}) | sort_by(-.count) | .[0:5]')

		# Add statistics to file
		cat >>"$scale_file" <<EOF
### 核心数据

- **PR总数**: ${scale_count}个
- **合并率**: ${merge_rate}% (${merged_count}已合并, ${open_count}开放中, ${closed_count}已关闭)
- **项目数量**: ${repos_count}个不同仓库
- **累计Stars**: ${total_stars}+

### 主要贡献仓库

EOF

		# Add top repos
		local repo_index=0
		while [ $repo_index -lt $(echo "$top_repos" | jq 'length') ]; do
			local repo
			repo=$(echo "$top_repos" | jq -r ".[$repo_index].repo")
			local stars
			stars=$(echo "$top_repos" | jq -r ".[$repo_index].stars")
			local count
			count=$(echo "$top_repos" | jq -r ".[$repo_index].count")
			echo "- **${repo}** (⭐ ${stars}): ${count}个PR" >>"$scale_file"
			repo_index=$((repo_index + 1))
		done

		# Add domain distribution
		cat >>"$scale_file" <<EOF

### 技术领域分布

\`\`\`
EOF

		# Calculate percentages for domain distribution
		for domain in "linux-kernel" "windows-drivers" "container-tech" "ai-infrastructure" "android" "gentoo-ecosystem"; do
			local count
			count=$(echo "$domain_counts" | jq ".[\"$domain\"]")

			if [ "$count" -eq 0 ]; then
				continue
			fi

			local percent
			percent=$(awk "BEGIN {printf \"%.0f\", 100 * $count / $scale_count}")

			local domain_name
			case $domain in
			"linux-kernel") domain_name="Linux内核/驱动" ;;
			"windows-drivers") domain_name="Windows驱动" ;;
			"container-tech") domain_name="容器技术   " ;;
			"ai-infrastructure") domain_name="AI基础设施 " ;;
			"android") domain_name="Android开发" ;;
			"gentoo-ecosystem") domain_name="Gentoo生态 " ;;
			esac

			# Create ASCII graph
			local bar=""
			local bar_length=$((percent / 5))
			for ((j = 0; j < bar_length; j++)); do
				bar="${bar}█"
			done
			for ((j = bar_length; j < 20; j++)); do
				bar="${bar}░"
			done

			echo "${domain_name}    ${bar} ${percent}% (${count}个PR)" >>"$scale_file"
		done

		cat >>"$scale_file" <<EOF
\`\`\`

---

## 🔍 项目详情

EOF

		# Get unique repositories
		local unique_repos
		unique_repos=$(echo "$scale_prs" | jq '[.[] | {repo_full_name, repo_stars}] | unique_by(.repo_full_name) | sort_by(-.repo_stars)')

		# For each repository
		local repo_index=0
		while [ $repo_index -lt $(echo "$unique_repos" | jq 'length') ]; do
			local repo_full_name
			repo_full_name=$(echo "$unique_repos" | jq -r ".[$repo_index].repo_full_name")
			local repo_stars
			repo_stars=$(echo "$unique_repos" | jq -r ".[$repo_index].repo_stars")

			# Get PRs for this repository
			local repo_prs
			repo_prs=$(echo "$scale_prs" | jq --arg repo "$repo_full_name" '[.[] | select(.repo_full_name==$repo)] | sort_by(.created_at)')

			# Add repository header
			cat >>"$scale_file" <<EOF
## ${repo_index+ 1}. ${repo_full_name} (⭐${repo_stars})

**项目简介**: 待填充 - 请手动添加项目描述  
**官网**: 待填充 - 请手动添加官网链接  
**GitHub**: https://github.com/${repo_full_name}

EOF

			# Add PRs for this repository
			local pr_index=0
			while [ $pr_index -lt $(echo "$repo_prs" | jq 'length') ]; do
				local pr
				pr=$(echo "$repo_prs" | jq ".[$pr_index]")

				local title
				title=$(echo "$pr" | jq -r '.title')
				local number
				number=$(echo "$pr" | jq -r '.number')
				local html_url
				html_url=$(echo "$pr" | jq -r '.html_url')
				local created_at
				created_at=$(echo "$pr" | jq -r '.created_at' | cut -d'T' -f1)
				local status
				status=$(echo "$pr" | jq -r '.status')

				# Determine status emoji
				local status_emoji
				if [ "$status" = "merged" ]; then
					status_emoji="✅"
				elif [ "$status" = "open" ]; then
					status_emoji="🟡"
				else
					status_emoji="❌"
				fi

				cat >>"$scale_file" <<EOF
### PR #${number} - ${title}

**基本信息**
- 🔗 **PR链接**: ${html_url}
- ⭐ **项目Stars**: ${repo_stars}
- 📅 **提交时间**: ${created_at}
- ${status_emoji} **状态**: ${status}

**问题描述**
待填充 - 此部分需要手动编辑，添加问题描述

**解决方案**
待填充 - 此部分需要手动编辑，添加解决方案

**技术亮点**
- 待填充 - 此部分需要手动编辑，添加技术亮点

**影响评估**
待填充 - 此部分需要手动编辑，添加影响评估

EOF

				pr_index=$((pr_index + 1))
			done

			repo_index=$((repo_index + 1))
		done

		cat >>"$scale_file" <<EOF
---

## 🎯 总结

### 核心技术能力展示

待填充 - 此部分需要手动编辑，总结在${title}项目中展示的核心技术能力

### 影响力指标

待填充 - 此部分需要手动编辑，总结在${title}项目的影响力

---

**文件版本**: v1.0  
**最后更新**: $(date +"%Y-%m-%d")  
**生成工具**: generate_wiki.sh
EOF

		log "INFO" "Generated ${scale}-projects.md"
	done
}

# Main function to run the script
main() {
	log "INFO" "==== Wiki Generation Script Started ===="

	# Check dependencies
	check_dependencies

	# Ensure directories exist
	ensure_directories

	# Check if we need to do full data collection
	local update_mode="all"
	if [ "$1" == "--update-year" ]; then
		update_mode="year"
		update_year="$2"
	elif [ "$1" == "--update-domain" ]; then
		update_mode="domain"
		update_domain="$2"
	fi

	if [ "$update_mode" == "all" ] || [ ! -f "${SCRIPTS_DIR}/enriched_prs.json" ]; then
		# Check GitHub token
		check_github_token

		# Fetch data
		fetch_user_info
		fetch_repositories
		fetch_pull_requests
		enrich_pull_requests

		# Generate metadata
		generate_metadata
	else
		log "INFO" "Using existing data..."
	fi

	# Generate markdown files
	if [ "$update_mode" == "all" ] || [ "$update_mode" == "year" ]; then
		if [ "$update_mode" == "year" ]; then
			log "INFO" "Only updating year: $update_year"
			# For year-specific update, we'd need to filter the data and regenerate
			# just that file, but that's complex for this script version
			# In a real implementation, you would extract this logic to a function and filter
		else
			generate_year_files
		fi
	fi

	if [ "$update_mode" == "all" ] || [ "$update_mode" == "domain" ]; then
		if [ "$update_mode" == "domain" ]; then
			log "INFO" "Only updating domain: $update_domain"
			# Similar to above, for domain-specific updates
		else
			generate_domain_files
			generate_scale_files
		fi
	fi

	log "INFO" "==== Wiki Generation Script Completed ===="
}

# Run the script with provided arguments
main "$@"
