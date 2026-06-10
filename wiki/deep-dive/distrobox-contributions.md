# distrobox - cgroup 委托与容器生命周期问题

> **核心问题**: rootless Podman、PID namespace、cgroup v2 delegation 在不同 init 系统下行为不一致
> **代表 PR**: [distrobox #1982](https://github.com/89luca89/distrobox/pull/1982), [distrobox #1987](https://github.com/89luca89/distrobox/pull/1987)
> **关联页面**: [大项目贡献](../by-scale/large-projects.md#1-89luca89distrobox-12016), [容器技术](../by-domain/container-tech.md)

---

## 1. 项目背景

[distrobox](https://github.com/89luca89/distrobox) 让用户在任意 Linux 发行版中运行其他发行版的容器环境，并通过 Podman/Docker 与宿主机桌面、HOME、设备等资源集成。

这类工具的难点不在「启动容器」本身，而在：

- rootless 模式权限边界；
- systemd / OpenRC / elogind 差异；
- cgroup v2 delegation；
- PID namespace 与宿主机进程可见性；
- Shell 脚本在复杂参数下的安全处理。

---

## 2. PR #1982: rootless + `--pid host` stop/rm 超时

### 2.1 表面现象

在非 systemd 系统（如 Gentoo OpenRC + elogind）上，使用 `--pid host` 的 rootless 容器停止或删除时可能超时：

```bash
distrobox create --name test --image alpine --additional-flags "--pid host"
distrobox stop test   # timeout
distrobox rm test     # timeout
```

典型错误：

```text
Error: timed out waiting for file /run/user/1000/libpod/tmp/exits/container-id
StopSignal SIGTERM failed to stop container in 10 seconds, resorting to SIGKILL
```

### 2.2 根因

`--pid host` 让容器进程处于宿主机 PID namespace。Podman 无法只通过容器 PID namespace 杀掉进程，只能依赖 cgroup 路径完成 freeze/kill/cleanup。

systemd 会自动建立 user slice delegation：

```text
/sys/fs/cgroup/user.slice/user-1000.slice/
├── cgroup.subtree_control
└── user@1000.service/...
```

非 systemd 环境缺少同等 delegation，rootless 用户可能无法正确清理容器 cgroup，最终表现为 stop/rm 超时。

### 2.3 处理策略

方案不是盲目延长 timeout，而是识别空 cgroup path 后切换清理路径：

```bash
cgroup_path=$(podman inspect "$container" --format '{{.State.CgroupPath}}')

if [ -z "$cgroup_path" ] || [ "$cgroup_path" = "/" ]; then
  # 非 systemd / delegation 不完整场景
  pids=$(podman top "$container" -eo pid | tail -n +2 | tr -d ' ')
  echo "$pids" | xargs -r kill -TERM || true
  podman stop --time 0 "$container" || podman rm -f "$container"
else
  podman stop "$container"
fi
```

---

## 3. PR #1987: force-delete 提示只显示目标运行容器

### 3.1 问题

`distrobox-rm --force` 批量删除时，提示列表可能混入未指定或已停止容器，造成误解甚至误删风险。

### 3.2 修复思路

- 只遍历用户明确传入的容器名；
- 只显示正在运行、确实需要 force-stop 的容器；
- 保持 Shell 参数引用和数组传递安全。

```bash
for container in "${containers[@]}"; do
  if container_exists "$container" && container_is_running "$container"; then
    echo "  - $container"
  fi
done
```

---

## 4. PR #985 / PID namespace 隔离链

[2026 年度贡献](../by-year/2026.md#-1月中) 记录了 distrobox PR #985：增强 PID 命名空间隔离，改进容器内进程可见性控制，解决 systemd 服务在特定条件下无法启动的问题。这与 #1982 属于同一条问题链：容器工具需要在「集成宿主」和「隔离容器」之间做精细取舍。

---

## 5. 技术价值

| 能力 | 体现 |
|------|------|
| 跨发行版分析 | Gentoo OpenRC/elogind 与 systemd 行为差异 |
| 容器底层理解 | PID namespace、cgroup v2、rootless Podman |
| Shell 工程 | 安全数组传参、清晰提示、回退策略 |
| 用户体验 | 防止误删，减少非 systemd 用户的 stop/rm 卡死 |

---

## 6. 与其他项目的迁移

- LibreChat Podman 支持：把本地 Podman 经验迁移到 AI Web 应用部署；
- Gentoo OpenRC 维护：同样关注非 systemd 环境的一等支持；
- ChatBot-Proxy / MCP 部署：容器运行时差异影响 AI 服务部署方式。

---

## 7. 关联阅读

- [大项目贡献 - distrobox](../by-scale/large-projects.md#1-89luca89distrobox-12016)
- [容器技术](../by-domain/container-tech.md)
- [个人项目 distrobox-plus](../personal-projects/distrobox-plus.md)
- [贡献交叉引用表 - 容器技术演进](../CROSS_REFERENCES.md#容器技术演进-2025-2026)

---

**文件版本**: v1.0
**最后更新**: 2026-06-10
