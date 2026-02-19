# Gentoo生态

> 长期维护开源软件包，专注 OpenRC 支持和多仓库贡献

---

## 📊 技术领域概览

- **涵盖仓库**: gentoo, gentoo-zh, guru, xarblu-overlay, 其他overlays
- **贡献类型**: 软件包维护, 构建修复, OpenRC服务, 新增包
- **贡献数量**: 约 90+ PRs
- **技术栈**: Shell, ebuild, Portage, OpenRC
- **主要时间**: 2023-2026 (活跃维护)

---

## 1. Gentoo 官方仓库贡献

[gentoo/gentoo](https://github.com/gentoo/gentoo) (⭐2,328) 是 Gentoo Linux 发行版的官方软件包仓库。

### PR #45057: kde-plasma/krdp: add OpenRC rc file in 6.5.4

为 KDE Plasma 的远程桌面组件添加 OpenRC 启动脚本，增强在 OpenRC 系统上的体验。

**代码实现**:
```bash
#!/sbin/openrc-run
# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

description="KDE Remote Desktop Server"
command="/usr/bin/krdp-server"
command_background="yes"
pidfile="/run/${RC_SVCNAME}.pid"

depend() {
    need dbus
    use logger
}

# 标准输出/错误重定向
start_pre() {
    checkpath -d -m 0755 -o root:root /var/log/krdp
}

start() {
    ebegin "Starting KDE Remote Desktop Server"
    start-stop-daemon --start --quiet --background \
        --make-pidfile --pidfile "${pidfile}" \
        --exec "${command}" -- ${command_args} \
        1>>/var/log/krdp/krdp.log 2>&1
    eend $?
}
```

**技术亮点**:
- 遵循 OpenRC 最佳实践，包括依赖声明和日志管理
- 使用标准 start-stop-daemon 确保正确进程管理
- 考虑了最小权限原则和安全性

## 2. Gentoo 中文社区贡献

[microcai/gentoo-zh](https://github.com/microcai/gentoo-zh) 是 Gentoo 中文社区维护的 Overlay，包含大量适合中文用户的软件包。在此成为活跃维护者，贡献了40+个PR。

### 持续维护的核心软件包

**OpenCode 系列** (持续快速迭代):
- PR #9412: dev-util/opencode-bin: add 1.2.6, drop 1.2.5 (2026-02-17)
- PR #9399: dev-util/opencode-bin: add 9999 live ebuild (2026-02-16)
- PR #9398: dev-util/opencode-bin: add 1.2.5, drop 1.2.4 (2026-02-16)
- PR #9392: dev-util/opencode-bin: add 1.2.4, drop 1.2.1 (2026-02-15)
- PR #9385: dev-util/opencode-bin: add 1.2.1, drop 1.1.65 (2026-02-14)
- PR #9379: dev-util/opencode-bin: add 1.1.65, drop 1.1.48 (2026-02-14)
- PR #9299: dev-util/opencode-bin: add 1.1.49, drop 1.1.48 (2026-02-04)
- PR #9269: dev-util/opencode-bin: new package, add 1.1.48 (2026-01-31)

**Anytype 系列**:
- PR #9422: app-office/anytype-bin: add 0.54.2, drop 0.54.1 (2026-02-19)
- PR #9413: app-office/anytype-bin: add 0.54.1, drop 0.53.1, drop 0.35.4 (2026-02-17)

**系统工具**:
- PR #8862/6621: sys-power/tlpui: enable py3.14/py3.13 支持
- PR #5284: sys-power/tlpui: add 1.6.5 (新版本更新)

**网络代理工具**:
- PR #8468/8245/8217: net-proxy/clash-verge-bin: fix/add/update
- PR #7150/7140: 添加和更新 clash-verge-bin OpenRC 服务

**开发工具**:
- PR #5687/5369/4913: 持续更新 dev-util/android-studio
- PR #4510: dev-util/android-studio: new package, add 2023.2.1.25

### PR #7140: 为 clash-verge-bin 添加 OpenRC 服务

为热门代理工具添加 OpenRC 系统支持:

```bash
#!/sbin/openrc-run
# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

name="Clash Verge"
description="A Clash Meta GUI based on Tauri"

: ${CLASH_VERGE_USER:=nobody}
: ${CLASH_VERGE_GROUP:=nobody}
: ${CLASH_VERGE_CONFIG_DIR:="/etc/clash-verge"}
: ${CLASH_VERGE_CORE:="clash-meta"} # clash | clash-meta | clash-rs

command="/opt/clash-verge/chrome-sandbox"
command_args="--no-sandbox --core-type=\"${CLASH_VERGE_CORE}\" --config-dir=\"${CLASH_VERGE_CONFIG_DIR}\""
command_background=true
pidfile="/run/${RC_SVCNAME}.pid"
start_stop_daemon_args="--user ${CLASH_VERGE_USER} --group ${CLASH_VERGE_GROUP}"

depend() {
    need net
    after network-online
    use network-online
}

start_pre() {
    if [ ! -d "${CLASH_VERGE_CONFIG_DIR}" ]; then
        eerror "配置目录 ${CLASH_VERGE_CONFIG_DIR} 不存在"
        return 1
    fi
    
    # 确保权限正确
    checkpath -d -m 0755 -o ${CLASH_VERGE_USER}:${CLASH_VERGE_GROUP} "${CLASH_VERGE_CONFIG_DIR}"
}
```

**技术亮点**:
- 使用环境变量实现灵活配置
- 实现正确的用户权限降级
- 全面的依赖管理和错误处理

## 3. Gentoo GURU 仓库贡献

[gentoo/guru](https://github.com/gentoo/guru) 是社区维护的高质量 Overlay，经过严格质量控制。

### 重点贡献

**虚拟化工具**:
- PR #411: app-emulation/quickemu: add 9999 (2026-01-03)

**系统工具**:
- PR #397: sys-power/auto-cpufreq: add 2.6.0 (2025-11-15)
- PR #240: sys-power/auto-cpufreq: add 2.4.0 (2024-09-12)

**开发工具**:
- PR #218: app-editors/emacs-lsp-booster: add 0.2.1, drop 0.2.0
- PR #197: dev-build/just-1.28.0: fix install
- PR #168: dev-util/bash-language-server: update SRC_URI

### PR #397: sys-power/auto-cpufreq: add 2.6.0

更新 CPU 频率自动调节工具：

```bash
# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1 linux-info optfeature systemd

DESCRIPTION="Automatic CPU speed & power optimizer for Linux"
HOMEPAGE="https://github.com/AdnanHodzic/auto-cpufreq"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/AdnanHodzic/auto-cpufreq.git"
else
	SRC_URI="https://github.com/AdnanHodzic/auto-cpufreq/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="systemd"

DEPEND="${PYTHON_DEPS}"
RDEPEND="
	${DEPEND}
	dev-python/psutil[${PYTHON_USEDEP}]
	sys-power/cpufrequtils
	sys-process/procps
"

pkg_setup() {
	linux_config_exists
	CONFIG_CHECK="CPU_FREQ"
	ERROR_CPU_FREQ="需要 CONFIG_CPU_FREQ: 'CPU Frequency scaling'"
	check_extra_config
}

python_install_all() {
	distutils-r1_python_install_all
	
	# 安装 OpenRC 服务
	newinitd "${FILESDIR}"/${PN}-openrc ${PN}
	
	# systemd 服务处理
	if use systemd; then
		systemd_dounit "${S}"/scripts/auto-cpufreq.service
	fi
}

pkg_postinst() {
	optfeature "better statistics display" dev-python/distro
	
	einfo "要启用服务，请运行:"
	if use systemd; then
		einfo "systemctl enable --now auto-cpufreq"
	else
		einfo "rc-update add auto-cpufreq default"
		einfo "rc-service auto-cpufreq start"
	fi
}
```

**技术亮点**:
- 跨 init 系统支持 (OpenRC 和 systemd)
- 内核配置检查确保必要模块
- 完善的依赖管理和可选功能提示

## 4. 其他 Overlay 贡献

### CachyOS 相关贡献
- **Szowisz/CachyOS-kernels** (活跃维护):
  - 2026-02-18: 更新 PRJC 调度器补丁 (6.19.2)
  - 2026-02-17: 添加 6.18.12, 6.19.2 内核版本
  - 2026-02-14: 添加 6.18.10 内核版本
  - 2026-02-12: 修复 musl/LLVM profiles 不依赖 GCC 的支持 (6.6.x LTS)
  - 2026-02-12: 修复 llvm-lto USE flag 冲突
  - PR #14: Add cachyos-sources-6.8.8.ebuild, drop 6.8.4
  - PR #13: Fix cachyos-sources-6.8.4 ebuild

### 桌面环境相关
- **xarblu/xarblu-overlay**:
  - PR #507: sys-kernel/scx-1.0.2: fix cargo dependence
  - PR #401: sys-kernel/scx: add 0.1.8

### Wayland 相关
- **bsd-ac/wayland-desktop**:
  - PR #64: gui-apps/waylock: Update BDEPEND limit of zig 0.10

### 安全工具相关
- **beatussum/save-backlight**:
  - PR #2: remove * in openrc-run script

## 5. 生态贡献概览

### 按软件类别划分

| 类别 | PR数量 | 代表项目 |
|------|--------|---------|
| **开发工具** | ~25 | opencode-bin, android-studio, bash-language-server, emacs-lsp-booster |
| **网络工具** | ~15 | clash-verge-bin, daed, anytype-bin |
| **系统工具** | ~15 | tlpui, auto-cpufreq, linux-enable-ir-emitter |
| **虚拟化** | ~10 | quickemu, distrobox-boost, deepin-wine |
| **图形界面** | ~10 | lceda-pro, river, swww |
| **内核** | ~10 | cachyos-sources (6.6 LTS ~ 6.19) |
| **其他** | ~10 | zprint-bin, proton-authenticator-bin, rustdesk |

### ebuild开发技术要点

- **版本槽管理**：确保平滑升级和多版本共存
- **Python实现兼容性**：支持多个Python版本
- **依赖分析**：精确控制构建和运行时依赖
- **USE标志**：提供灵活的功能配置选项
- **init系统兼容**：同时支持OpenRC和systemd
- **安全考量**：最小权限原则和沙盒构建

## 🎯 总结与技能展示

### 核心技能
- 深入理解Gentoo Portage包管理系统
- 熟练掌握ebuild编写和维护
- 对各种软件构建系统有广泛了解
- OpenRC服务脚本设计与优化

### 社区影响
- 为Gentoo生态贡献90+个PR
- 提供大量OpenRC支持，改善非systemd用户体验
- 维护一系列对中国用户有用的软件包
- 活跃的gentoo-zh维护者

---

**文件版本**: v1.1  
**最后更新**: 2026-02-19

