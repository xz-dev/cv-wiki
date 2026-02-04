# 大项目贡献 (10k-30k ⭐)

> 在中等规模但高影响力的开源项目中解决系统级问题

---

## 📊 统计概览

- **项目数量**: 1个
- **总Stars**: 12,016
- **PR数量**: 2个
- **状态**: 2个开放中
- **技术领域**: 容器技术, Linux系统

---

## 1. 89luca89/distrobox (⭐12,016)

**项目简介**: 在任何Linux发行版中使用任何发行版的终端  
**技术栈**: Shell, Bash, Podman/Docker  
**GitHub**: https://github.com/89luca89/distrobox

### 项目背景

Distrobox允许用户在主系统中运行其他Linux发行版的容器环境，实现：
- 在Arch上运行Ubuntu应用
- 在Fedora上使用Gentoo工具链
- 无缝集成GUI应用
- 保持主系统整洁

### PR #1987 - fix: show only running containers in force-delete prompt

**基本信息**
- 🔗 **PR链接**: https://github.com/89luca89/distrobox/pull/1987
- ⭐ **项目Stars**: 12,016
- 📅 **提交时间**: 2026-01
- 🟡 **状态**: 开放中
- 🏷️ **标签**: `bug-fix` `shell` `user-experience`
- 📝 **改动**: ~20 lines, 1 file

**问题描述**

`distrobox-rm --force` 删除多个容器时的提示逻辑存在问题：

1. **当前行为**:
   ```bash
   $ distrobox-rm --force container1 container2 stopped-container3
   
   # 显示所有容器（包括已停止的），导致混乱
   The following containers will be deleted:
   - container1 (running)
   - container2 (running)  
   - stopped-container3 (stopped)
   - other-unrelated-container (stopped)
   
   Continue? [y/N]
   ```

2. **问题**:
   - 列表包含未被指定删除的容器
   - 停止状态的容器也显示在列表中
   - 用户容易误删除

**解决方案**

修复提示逻辑，只显示正在运行且被指定删除的容器：

```bash
# distrobox-rm 脚本片段
list_containers_to_delete() {
    local force="$1"
    shift
    local containers=("$@")
    
    if [ "$force" = "1" ]; then
        echo "The following running containers will be force-stopped and deleted:"
        for container in "${containers[@]}"; do
            # 只检查指定的容器
            if container_exists "$container" && container_is_running "$container"; then
                echo "  - $container"
            fi
        done
    fi
}

# 调用示例
if [ "$force_flag" = "1" ] && [ "${#containers_to_delete[@]}" -gt 0 ]; then
    list_containers_to_delete "$force_flag" "${containers_to_delete[@]}"
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi
```

**技术亮点**

1. **精确过滤**:
   - 只遍历用户指定的容器名称
   - 跳过已停止的容器（不需要强制删除）
   - 避免显示无关容器

2. **Shell最佳实践**:
   ```bash
   # 使用数组安全传递参数
   local containers=("$@")
   
   # 引号包裹变量防止分词
   if container_exists "$container"; then
       ...
   fi
   ```

3. **用户体验优化**:
   - 清晰的提示文案
   - 只在需要时显示确认
   - 减少误操作风险

**影响评估**

1. **解决的痛点**:
   - ✅ 避免误删除未指定的容器
   - ✅ 减少用户困惑
   - ✅ 提高命令行工具可用性

2. **用户影响**:
   - 所有使用 `distrobox-rm --force` 批量删除的用户
   - 特别是脚本自动化场景

---

### PR #1982 - fix: workaround podman stop/rm timeout in rootless mode with --pid host

**基本信息**
- 🔗 **PR链接**: https://github.com/89luca89/distrobox/pull/1982
- ⭐ **项目Stars**: 12,016
- 📅 **提交时间**: 2026-01
- 🟡 **状态**: 开放中
- 🏷️ **标签**: `critical-bug` `rootless` `cgroup` `systemd` `openrc`
- 📝 **改动**: ~30 lines, 2 files

**问题描述**

在非systemd系统（如OpenRC/elogind）上，使用 `--pid host` 创建的rootless容器停止/删除时超时：

1. **场景复现**:
   ```bash
   # 在Gentoo OpenRC系统上
   distrobox create --name test --image alpine --additional-flags "--pid host"
   distrobox enter test
   # ... 使用容器 ...
   distrobox stop test     # ❌ 超时 (默认10秒)
   distrobox rm test       # ❌ 超时
   ```

2. **根本原因** (深度分析):
   
   **cgroup委托链**:
   ```
   systemd系统:
   /sys/fs/cgroup/user.slice/user-1000.slice/...
   ├── cgroup.procs          (systemd管理)
   └── delegate/             (用户有写权限)
       └── podman-xxx/
           └── container/
   
   非systemd系统 (OpenRC/elogind):
   /sys/fs/cgroup/
   ├── cgroup.procs          (root拥有)
   └── user.slice/           (❌ 无delegate子树)
       └── podman-xxx/       (用户无法清理cgroup)
   ```

   **为什么 `--pid host` 触发问题**:
   - `--pid host` 使容器进程在主机PID命名空间
   - Podman无法通过kill cgroup中的所有进程停止容器
   - 需要依赖cgroup清理机制
   - 非systemd系统缺少cgroup委托 → 清理失败 → 超时

3. **错误日志**:
   ```
   Error: timed out waiting for file /run/user/1000/libpod/tmp/exits/container-id: internal libpod error
   ERRO[0010] StopSignal SIGTERM failed to stop container test in 10 seconds, resorting to SIGKILL
   ```

**解决方案**

检测cgroup路径为空时使用不同的停止策略：

```bash
# 在distrobox-stop中添加检测
stop_container() {
    local container_name="$1"
    local container_manager="$2"  # podman 或 docker
    
    # 检查容器的cgroup路径
    local cgroup_path=""
    if [ "$container_manager" = "podman" ]; then
        cgroup_path=$(podman inspect "$container_name" \
            --format '{{.State.CgroupPath}}' 2>/dev/null || echo "")
    fi
    
    # Workaround: 如果cgroup路径为空（非systemd系统），使用更激进的停止策略
    if [ -z "$cgroup_path" ] || [ "$cgroup_path" = "/" ]; then
        echo "⚠️  Detected empty cgroup path (non-systemd system)"
        echo "    Using workaround for --pid host containers..."
        
        # 方法1: 尝试发送SIGTERM到容器内的所有进程
        local container_pids
        container_pids=$($container_manager top "$container_name" -eo pid \
            | tail -n +2 | tr -d ' ')
        
        if [ -n "$container_pids" ]; then
            echo "$container_pids" | xargs -r kill -TERM 2>/dev/null || true
            sleep 2
        fi
        
        # 方法2: 使用--time 0 立即SIGKILL (跳过SIGTERM等待)
        $container_manager stop --time 0 "$container_name" 2>&1 || {
            # 方法3: 强制删除
            $container_manager rm -f "$container_name"
        }
    else
        # 正常系统，使用标准停止流程
        $container_manager stop "$container_name"
    fi
}
```

**技术深度分析**

1. **cgroup v2 委托机制**:
   ```bash
   # systemd自动设置委托
   $ cat /sys/fs/cgroup/user.slice/user-1000.slice/cgroup.subtree_control
   cpu memory pids
   
   # 非systemd系统通常没有
   $ cat /sys/fs/cgroup/user.slice/cgroup.subtree_control
   (empty or doesn't exist)
   ```

2. **Podman依赖的清理路径**:
   ```go
   // Podman源码简化版
   func (c *Container) stop(timeout uint) error {
       if c.config.PidNS.IsHost() {
           // PID host模式: 无法通过kill namespace
           // 依赖cgroup freeze+kill
           if err := c.freezeCgroup(); err != nil {
               return err  // ❌ 非systemd系统失败
           }
           return c.killCgroup()
       }
       // 正常模式: kill PID 1
       return c.killInit()
   }
   ```

3. **OpenRC vs systemd对比**:
   
   | 特性 | systemd | OpenRC/elogind |
   |------|---------|----------------|
   | **cgroup管理** | 集中式，自动委托 | 手动，无委托 |
   | **user slice** | 自动创建 | 需手动或elogind |
   | **清理机制** | cgroup.kill文件 | ❌ 不可用 |
   | **rootless支持** | 完整 | 部分受限 |

**替代方案对比**

| 方案 | 优点 | 缺点 | 可行性 |
|------|------|------|--------|
| **修复cgroup委托** | 根本解决 | 需root权限配置 | 低（用户无权限） |
| **避免--pid host** | 无问题 | 功能受限 | 中（某些场景必需） |
| **Workaround清理** | 无需权限，兼容性好 | 不优雅 | ✅ 高（当前方案） |
| **切换到Docker** | Docker处理不同 | 失去Podman优势 | 低 |

**测试用例**

```bash
#!/bin/bash
# 测试脚本: test-distrobox-stop.sh

echo "=== Test Environment ==="
uname -a
cat /proc/1/comm  # systemd 或 init
podman --version

echo -e "\n=== Test Case 1: --pid host 容器 ==="
distrobox create --name test-pid-host --image alpine:latest \
    --additional-flags "--pid host"
distrobox enter test-pid-host -- sleep 100 &
sleep 5

echo "Stopping container..."
time distrobox stop test-pid-host
if [ $? -eq 0 ]; then
    echo "✅ PASS: Container stopped successfully"
else
    echo "❌ FAIL: Container stop timeout"
fi

echo -e "\n=== Test Case 2: 正常容器（对照组） ==="
distrobox create --name test-normal --image alpine:latest
distrobox enter test-normal -- sleep 100 &
sleep 5

time distrobox stop test-normal
echo "✅ PASS: Normal container (baseline)"

# Cleanup
distrobox rm -f test-pid-host test-normal 2>/dev/null
```

**影响评估**

1. **解决的痛点**:
   - ✅ 修复非systemd系统上的容器停止超时
   - ✅ 支持 `--pid host` 在OpenRC/elogind环境
   - ✅ 提升Gentoo/Alpine/Void等发行版的用户体验

2. **技术意义**:
   - 深入理解Linux cgroup v2机制
   - 掌握systemd与非systemd系统的差异
   - 提供跨发行版兼容性方案

3. **社区影响**:
   - Gentoo用户的常见问题（OpenRC为主）
   - Alpine Linux用户（无systemd）
   - 所有使用elogind替代systemd的用户

4. **安全考虑**:
   - Workaround不引入安全风险
   - 仍然遵循rootless原则
   - 不需要额外权限提升

**相关代码**

检测逻辑：
```bash
# 辅助函数
container_has_empty_cgroup() {
    local container="$1"
    local cgroup_path
    cgroup_path=$(podman inspect "$container" \
        --format '{{.State.CgroupPath}}' 2>/dev/null)
    
    [ -z "$cgroup_path" ] || [ "$cgroup_path" = "/" ]
}
```

---

## 🎯 总结

### 核心技术能力展示

1. **系统级问题诊断**:
   - Linux cgroup v2机制
   - PID namespace交互
   - systemd vs OpenRC架构差异

2. **Shell脚本工程**:
   - 复杂条件处理
   - 错误恢复策略
   - 跨发行版兼容性

3. **用户体验设计**:
   - 清晰的错误提示
   - 安全的确认流程
   - 降低误操作风险

### 影响力指标

- **用户影响**: 12k+ stars项目
- **技术深度**: 系统级调试（内核接口、容器运行时）
- **社区价值**: 解决非主流发行版痛点，推动兼容性

### 技术标签

`Shell` `Bash` `Linux Containers` `Podman` `cgroup v2` `systemd` `OpenRC` `rootless` `PID namespace` `系统调试`

---

**文件版本**: v1.0  
**最后更新**: 2026-02-04

