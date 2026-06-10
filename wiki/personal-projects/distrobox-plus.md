# distrobox-plus - Python 重写 distrobox

> **定位**: 用 Python 重新实现 distrobox 的容器开发环境管理工具
> **技术栈**: Python 3.10+, Podman/Docker/lilipod, CLI 设计
> **仓库**: [xz-dev/distrobox-plus](https://github.com/xz-dev/distrobox-plus)
> **关联领域**: [容器技术](../by-domain/container-tech.md), [distrobox 深度分析](../deep-dive/distrobox-contributions.md)

---

## 项目概览

`distrobox-plus` 是对 [distrobox](https://github.com/89luca89/distrobox) 思路的 Python 实现，用于创建和管理容器化开发环境。项目目标不是替代上游生态，而是通过 Python 代码结构实验更清晰的容器管理抽象。

| 属性 | 值 |
|------|-----|
| 语言 | Python |
| Python 版本 | 3.10+ |
| 容器后端 | podman, docker, lilipod |
| 安装方式 | `uv tool install distrobox-plus` / `pip install distrobox-plus` |
| License | BSD 3-Clause |

---

## 核心功能

支持原 distrobox 的主要命令族：

- `create` — 创建新容器；
- `enter` — 进入容器；
- `list` — 列出容器；
- `rm` / `stop` — 删除和停止容器；
- `upgrade` — 升级容器；
- `assemble` — 从 manifest 创建容器；
- `ephemeral` — 创建临时容器；
- `export` / `generate-entry` — 导出应用、服务和 desktop entry。

---

## 架构要点

### 1. 容器后端抽象

项目把容器运行时检测与命令实现分离：

```python
class ContainerManager:
    def __init__(self, runtime='auto'):
        self.runtime = self._detect_runtime() if runtime == 'auto' else runtime
        self.engine = self._get_engine_class()()

    def create(self, name, image, additional_flags=None):
        return self.engine.create(name, image, additional_flags)
```

这样可以在 Podman、Docker、lilipod 之间切换，并为不同后端保留差异化处理空间。

### 2. CLI 与测试

开发工作流使用 `uv`：

```bash
uv sync --group dev
uv run pytest
uv run pytest -m fast
```

这使项目适合作为容器 CLI 的快速实验场：既可保留 distrobox 的用户体验，也可用 Python 测试覆盖复杂分支。

---

## 技术意义

- **容器模型理解**: 将 Shell 工具重写为 Python，需要明确抽象容器生命周期、运行时能力和错误处理；
- **可测试性提升**: Python 结构更利于单元测试和后端 mock；
- **经验反哺上游**: 对 distrobox stop/rm、PID namespace、cgroup 问题的理解，可迁移回上游贡献；
- **开发环境自动化**: 面向多发行版开发环境快速创建和清理。

---

## 关联阅读

- [容器技术](../by-domain/container-tech.md#3-个人项目-distrobox-plus)
- [distrobox 深度分析](../deep-dive/distrobox-contributions.md)
- [大项目贡献 - distrobox](../by-scale/large-projects.md#1-89luca89distrobox-12016)

---

**文件版本**: v1.0
**最后更新**: 2026-06-10
