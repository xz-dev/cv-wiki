# xz-dev 博客分析 (xzos.net)

> **分析日期**: 2026-02-04  
> **博客地址**: https://xzos.net/  
> **活跃时间**: 2017年7月至今 (约8年)

---

## 基本信息

| 项目 | 内容 |
|------|------|
| **博客 URL** | https://xzos.net/ |
| **About 页面** | https://xzos.net/introduction |
| **文章数量** | 55+ 篇技术文章 |
| **最新更新** | 2026年2月 |
| **技术栈** | Astro v5.17.1 |
| **评论系统** | Remark42 |

---

## 联系方式与社交账号

### 代码平台
- **GitHub**: [https://github.com/xz-dev](https://github.com/xz-dev)
- **GitLab**: [https://gitlab.com/xz-dev](https://gitlab.com/xz-dev)
- **Codeberg**: [https://codeberg.org/xz-dev](https://codeberg.org/xz-dev)

### 社交媒体
- **Mastodon**: [https://fosstodon.org/@xzdev](https://fosstodon.org/@xzdev)
- **Matrix**: @inkflaw:matrix.org

### 其他
- **简历**: [https://xzos.net/cv/](https://xzos.net/cv/) (中英双语版)
- **Donate**: [https://ko-fi.com/xz117514](https://ko-fi.com/xz117514)

---

## Stack Exchange 社区贡献

xz-dev 在多个 Stack Exchange 社区活跃，使用用户名 **inkflaw**：

| 平台 | 链接 | 主题 |
|------|------|------|
| **Stack Overflow** | [链接](https://stackoverflow.com/users/15715806/inkflaw) | 编程问答 |
| **Ask Ubuntu** | [链接](https://askubuntu.com/users/2416571/inkflaw) | Ubuntu 系统 |
| **Server Fault** | [链接](https://serverfault.com/users/1054048/inkflaw) | 服务器运维 |
| **Unix & Linux** | [链接](https://unix.stackexchange.com/users/492540/inkflaw) | Unix/Linux |
| **Emacs** | [链接](https://emacs.stackexchange.com/users/39834/inkflaw) | Emacs 编辑器 |
| **Super User** | [链接](https://superuser.com/users/1861122/inkflaw) | 通用计算机 |

**意义**: Stack Exchange 贡献展示了问题解决能力和社区参与度，是开源贡献的重要补充。

---

## 博客内容分类

### 内容分布

```
Linux 系统管理  ████████████████████ 40%
网络/运维技术    ████████████░░░░░░░░ 25%
开发技术         ████████░░░░░░░░░░░░ 20%
AI/工具          ████░░░░░░░░░░░░░░░░ 10%
生活随笔         ██░░░░░░░░░░░░░░░░░░  5%
```

---

### 1. Linux 系统管理 (约40%)

**核心主题**: ArchLinux 配置、文件系统、休眠、桌面环境

#### 代表性文章

| 文章 | 日期 | 技术点 |
|------|------|--------|
| [ArchLinux 配置指南](https://xzos.net/blog/archlinux-setup-guide/) | 2020-10-21 | 系统配置导航页，涵盖 KDE、Swap、Pacman |
| [Arch Linux 使用 Swap File 进行休眠](https://xzos.net/blog/arch-linux-hibernation-into-swap-file/) | 2019-06-08 | 休眠配置、GRUB 参数 |
| [修改 EXT4 根目录文件系统为 XFS](https://xzos.net/blog/change-root-file-system-from-ext4-to-xfs-on-archlinux/) | 2019-10-19 | 文件系统迁移 |
| [LVM 保留数据平滑替换物理磁盘](https://xzos.net/blog/lvm-replace-hard-driveand-move-data/) | 2019-09-03 | LVM 管理 |
| [使用 timeshift 重装 Arch Linux](https://xzos.net/blog/reload-archlinux-with-timeshift/) | 2019-02-27 | 系统备份恢复 |
| [KDE 最小安装方案](https://xzos.net/blog/kde-minimum-installation-solution-for-arch-linux/) | 2019-05-18 | 桌面环境 |
| [Pacman 通用配置](https://xzos.net/blog/my-pacman-conf/) | 2020-10-19 | 包管理器配置 |
| [Ubuntu、Fedora 与 Nvidia 驱动](https://xzos.net/blog/ubuntu-fedora-nvidia/) | 2018-06-24 | 显卡驱动 |

**技术深度评估**: 95/100

展示了对 Linux 系统的深入理解，从文件系统选择到休眠配置，涵盖系统管理的各个层面。

---

### 2. 网络/运维技术 (约25%)

**核心主题**: 代理部署、负载均衡、Docker 容器化

#### 代表性文章

| 文章 | 日期 | 技术点 |
|------|------|--------|
| [Docker 部署 V2Ray](https://xzos.net/blog/docker-deploy-v2ray/) | 2019-05-18 | Docker、多协议配置 |
| [WebSocket+TLS+CDN+Web Apache2 部署V2Ray](https://xzos.net/blog/websockettlscdnweb-apache2-deploys-v2ray/) | 2020-06-05 | 安全代理架构 |
| [V2Ray 多协议使用 HAProxy 负载均衡](https://xzos.net/blog/load-balancing-v2ray-with-haproxy-and-docker/) | 2019-11-23 | 负载均衡、网络架构 |
| [HAProxy 与 ShadowSocks](https://xzos.net/blog/haproxy-shadowsocks/) | 2018-06-27 | 代理配置 |
| [Docker 安装 WordPress 并迁移数据](https://xzos.net/blog/docker-install-wordpress/) | 2019-07-26 | WordPress、数据迁移 |

**技术深度评估**: 85/100

多种部署方案展示了清晰的架构思维和实际运维经验。

---

### 3. 开发技术 (约20%)

**核心主题**: Python 自动化、Android 开发、算法、Git

#### 代表性文章

| 文章 | 日期 | 技术点 |
|------|------|--------|
| [代码即操作系统 - UpgradeAll 2 开发计划](https://xzos.net/blog/code-as-operating-system-upgradeall-2-development-plan/) | 2023-10-18 | 项目规划、架构设计 |
| [dom4j 的 proguard-rules 配置分享](https://xzos.net/blog/dom4j-proguard-rules/) | 2022-09-07 | Android 混淆配置 |
| [Python3 下载并解析 xml.gz 文件](https://xzos.net/blog/python3-use-raw-data-parsing-xml-gz-file/) | 2020-05-28 | Python 数据处理 |
| [Cut and move Runs via python-docx](https://xzos.net/blog/cut-and-move-runs-via-python-docx/) | 2024-03-19 | Python 文档处理 |
| [手动线刷任意 Android ROM](https://xzos.net/blog/flash-android-rom-by-fastboot-payload_dumper/) | 2023-04-22 | Android 系统 |
| [Range Sum Query 2D (LeetCode)](https://xzos.net/blog/range-sum-query-2d/) | 2021-05-12 | 算法、动态规划 |
| [修改一个历史提交的父提交](https://xzos.net/blog/how-to-swap-the-order-of-two-parents-of-a-git-commit/) | 2021-02-06 | Git 高级操作 |
| [Azure Custom Vision: Managed Identity](https://xzos.net/blog/azure-custom-vision-mi/) | 2025-01-01 | Azure 云服务 |

**技术深度评估**: 80/100

展示了多语言开发能力和解决实际问题的能力。

---

### 4. AI/工具相关 (约10%)

**核心主题**: AI 工具思考、媒体处理、自动化

#### 代表性文章

| 文章 | 日期 | 技术点 |
|------|------|--------|
| [AI 时代的脑腐症](https://xzos.net/blog/brain-rot-in-ai-era/) | 2026-02-02 | AI 时代思考 |
| [AI 时代的手动测试革命](https://xzos.net/blog/ai-driven-manual-testing-revolution/) | 2025-07-18 | AI 辅助测试 |
| [AI 撰写 Post 的有趣观察](https://xzos.net/blog/ai-write-post-observed-phenomena/) | 2025-09-02 | AI 内容生成 |
| [批量修复 DJI Mimo 导出照片/视频时间](https://xzos.net/blog/dji-mimo-photo-date-fix/) | 2026-01-04 | 媒体处理自动化 |
| [WebM/WebP to GIF with semi-transparency](https://xzos.net/blog/webm-webp-to-gif-with-semi-transparency/) | 2024-09-15 | 图像格式转换 |
| [迁移 Google Photo 到云上贵州 iCloud Photo](https://xzos.net/blog/merge-google-photo-to-icloud-photo-china/) | 2025-03-07 | 数据迁移 |

**技术深度评估**: 75/100

展示了对新技术的关注和实用主义态度。

---

### 5. 生活随笔 (约5%)

个人感想、四级考试、节日祝福等非技术内容。

---

## 技术成长轨迹

### 时间线

```
2017 ─────────────────────────────────────────────────────────► 2026
  │                                                              │
  ▼                                                              ▼
入门阶段              Linux深度探索        开发提升        AI工具思考
(Kindle/基础)         (ArchLinux系列)      (算法/自动化)   (AI时代反思)
    │                     │                    │              │
2017-2018             2019-2020           2021-2024       2025-2026
```

### 阶段特点

| 阶段 | 时间 | 特点 |
|------|------|------|
| **入门** | 2017-2018 | Kindle、基础 Linux、LineageOS 适配计划 |
| **深度探索** | 2019-2020 | ArchLinux 系列、网络运维、Docker |
| **开发提升** | 2021-2024 | 算法题解、Python 自动化、项目规划 |
| **AI 时代** | 2025-2026 | AI 工具思考、云服务集成 |

---

## 写作风格分析

### 优点

1. **结构清晰**: 善用导航页组织系列文章（如 ArchLinux 配置指南）
2. **实战导向**: 重视可复现性，提供完整步骤
3. **问题记录**: 详细记录踩坑和解决方案
4. **双语能力**: 中英文技术文章均有

### 特点

- 使用代码块展示命令和配置
- 提供 ArchWiki 等权威参考链接
- 文章附带评论系统，鼓励互动

---

## 综合评估

### 技能矩阵 (基于博客内容)

```
Linux 系统管理   ████████████████████ 95%
网络/运维        █████████████████░░░ 85%
Docker/容器      ████████████████░░░░ 80%
Python           ███████████████░░░░░ 75%
Android          ██████████████░░░░░░ 70%
Web 开发         ████████████░░░░░░░░ 60%
```

### 关键发现

1. **持续学习者**: 8年持续更新，内容随技术栈演进
2. **实践导向**: 大量实战记录，解决实际问题
3. **社区活跃**: Stack Exchange 多平台贡献
4. **开源精神**: 提供简历、捐赠渠道，透明开放
5. **多语言能力**: 中英文技术写作

### 用于招聘评估

| 评估项 | 来源 | 价值 |
|--------|------|------|
| 技术深度 | 博客文章 | 展示实际解决问题能力 |
| 持续学习 | 8年更新历史 | 证明学习能力和热情 |
| 社区贡献 | Stack Exchange | 问题解决和沟通能力 |
| 开放透明 | 简历/捐赠链接 | 专业态度 |

---

## 快速访问

- **简历下载**: [中英双语版](https://xzos.net/cv/xiangzhe_cv-zh_en.pdf) | [English](https://xzos.net/cv/xiangzhe_cv.pdf) | [中文版](https://xzos.net/cv/%E6%9B%BE%E7%A5%A5%E5%93%B2%E7%9A%84%E7%AE%80%E5%8E%86.pdf)
- **博客首页**: https://xzos.net/blog
- **About 页面**: https://xzos.net/introduction

---

**文档版本**: v1.0  
**最后更新**: 2026-02-04  
**维护者**: xz-dev
