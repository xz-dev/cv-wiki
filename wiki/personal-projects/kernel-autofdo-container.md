# kernel-autofdo-container - Linux 内核 AutoFDO / Propeller Profile 生成工具

> **定位**: 容器化生成 Linux kernel AutoFDO 和 Propeller 优化 profile
> **技术栈**: Podman, perf, Phoronix Test Suite, AutoFDO, Propeller
> **仓库**: [xz-dev/kernel-autofdo-container](https://github.com/xz-dev/kernel-autofdo-container)
> **关联领域**: [Linux/BSD 内核与驱动](../by-domain/linux-kernel.md), [容器技术](../by-domain/container-tech.md)

---

## 项目概览

`kernel-autofdo-container` 将内核 profile 采集流程封装进容器，利用 Phoronix Test Suite 运行负载，通过 `perf` 采样生成可用于内核 PGO 的 AutoFDO / Propeller profile。

| 属性 | 值 |
|------|-----|
| 运行方式 | Podman container |
| 输入 | 当前内核匹配的 `vmlinux` debug symbols |
| 输出 | `kernel.afdo`, Propeller cc/ld profile |
| 权限 | 需要 `--privileged` 访问性能计数器 |
| 推荐资源 | 16GB+ RAM，独立测试环境 |

---

## 工作流程

项目 README 给出的完整流程：

1. 构建初始内核；
2. 重启到该内核；
3. 生成 AutoFDO profile；
4. 使用 AutoFDO profile 重新构建内核；
5. 重启到新内核；
6. 生成 Propeller profile；
7. 使用 AutoFDO + Propeller profile 构建最终内核；
8. 重启并验证性能。

---

## 使用方式

### 构建容器

```bash
podman build -t autofdo .
```

### 生成 AutoFDO profile

```bash
podman run --rm   -v $PWD/output:/output   -v /usr/lib/modules/$(uname -r)/build/vmlinux:/vmlinux   -it --privileged   autofdo /vmlinux amd autofdo
```

### 生成 Propeller profile

```bash
podman run --rm   -v $PWD/output:/output   -v /usr/lib/modules/$(uname -r)/build/vmlinux:/vmlinux   -it --privileged   autofdo /vmlinux amd propeller
```

---

## Workload 覆盖

README 中的 CPU workload 覆盖多种内核/用户态压力类型：

- 编译: `pts/build-linux-kernel`, `pts/build-gcc`；
- 编码/压缩: `pts/x264`, `pts/x265`, `pts/kvazaar`, `pts/compress-7zip`；
- 计算: `pts/stockfish`, `pts/openssl`, `pts/sysbench`, `pts/povray`；
- 图形/渲染: `pts/blender`, `pts/radiance`。

这些负载让 profile 不只针对单一 benchmark，而是覆盖编译、压缩、加密、渲染等常见 CPU 路径。

---

## 性能验证

项目 README 记录了 OpenBenchmarking 对比结果：

1. 无 kernel optimization profiles: https://openbenchmarking.org/result/2502094-NE-CPU25415319
2. AutoFDO + Propeller: https://openbenchmarking.org/result/2502105-NE-CPU23727229

---

## 技术亮点

| 能力 | 体现 |
|------|------|
| 内核性能工程 | 理解 AutoFDO/Propeller 与内核构建链的关系 |
| 容器化实验 | 用 Podman 固化复杂 profile 采集环境 |
| Benchmark 设计 | 使用 Phoronix Test Suite 覆盖多类 workload |
| 可复现性 | 固定输出目录和参数，便于多轮 profile 构建 |

---

## 注意事项

- `vmlinux` 必须与当前运行内核匹配；
- `--privileged` 是性能采样所需，不适合在不受信任环境运行；
- profile 采集会产生高 CPU/内存负载，建议在专用机器或空闲时间运行；
- 输出目录需要有写权限。

---

## 关联阅读

- [Linux/BSD 内核与驱动](../by-domain/linux-kernel.md)
- [容器技术](../by-domain/container-tech.md)
- [贡献交叉引用表 - 系统编程与底层优化](../CROSS_REFERENCES.md#系统编程与底层优化)

---

**文件版本**: v1.0
**最后更新**: 2026-06-10
