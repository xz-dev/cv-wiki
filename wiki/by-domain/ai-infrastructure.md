# AI基础设施

> 构建大型语言模型的工具集成平台，专注于 MCP 协议实现与企业级集成

---

## 📊 技术领域概览

- **核心项目**: modelcontextprotocol/servers (⭐77,980), rss-mcp, video_viewer_mcp
- **贡献类型**: 架构优化, 功能开发, OAuth集成, 进程隔离
- **技术栈**: TypeScript, Python, MCP, OAuth, Playwright
- **工作经历**: Klavis AI (2024-2025.12) - MCP 集成开发
- **个人项目**: 多个 MCP 工具开发

---

## 1. MCP 服务器核心架构改进

### modelcontextprotocol/servers PR #3286: 文件锁支持多实例

[MCP Servers](https://github.com/modelcontextprotocol/servers) (⭐77,980) 是 MCP 协议的官方实现，为 AI 代理提供多种工具调用能力。

**问题背景**:
当多个 AI 客户端同时使用 MCP 服务时，stdio 传输会创建独立进程，导致并发写入 memory.json 时出现竞争条件和数据损坏。

**架构挑战**:
传统的内存锁无法跨进程工作，需要实现真正的跨进程文件锁。

**解决方案**:
实现基于 `proper-lockfile` 的跨进程文件锁定机制：

```typescript
import { lock, unlock } from 'proper-lockfile';
import * as fs from 'fs';

// 原子读取操作
export async function readMemory<T>(
  filePath: string,
  defaultValue: T
): Promise<T> {
  try {
    // 获取文件锁（读锁）
    const release = await lock(filePath, { 
      retries: 10, 
      stale: 10000,
      realpath: false
    });
    
    try {
      // 在锁保护下读取
      const content = fs.readFileSync(filePath, 'utf-8');
      return JSON.parse(content) as T;
    } catch (error) {
      // 文件不存在或格式错误，返回默认值
      return defaultValue;
    } finally {
      // 确保总是释放锁
      await unlock(filePath, { realpath: false });
    }
  } catch (error) {
    // 获取锁失败（可能是超时）
    console.error('Failed to acquire lock for reading:', error);
    throw error;
  }
}

// 原子写入操作
export async function writeMemory<T>(
  filePath: string, 
  data: T
): Promise<void> {
  try {
    // 获取文件锁（写锁）
    const release = await lock(filePath, { 
      retries: 10, 
      stale: 10000,
      realpath: false
    });
    
    try {
      // 在锁保护下写入
      const content = JSON.stringify(data, null, 2);
      fs.writeFileSync(filePath, content, 'utf-8');
    } finally {
      // 确保总是释放锁
      await unlock(filePath, { realpath: false });
    }
  } catch (error) {
    // 获取锁失败
    console.error('Failed to acquire lock for writing:', error);
    throw error;
  }
}
```

**并发测试**:
- 单进程 10,000 并发写入测试
- 5 个进程各 2,000 并发写入测试
- 所有测试无数据损坏或丢失

**技术亮点**:
- 使用 Node.js 原生 fs 模块保证最大兼容性
- 采用指数退避策略处理锁争用
- 防止死锁的自动过期机制
- 完整的错误处理和恢复策略

## 2. Klavis AI 工作期间的 MCP 集成

在 Klavis AI 工作期间 (2024-2025.12)，领导开发了多个 MCP 服务器，实现 AI 与各种第三方服务的集成。

### Playwright MCP 服务器

**PR #788**: 添加具备进程隔离能力的 Playwright MCP 服务器。

**核心架构**:
```python
class PlaywrightProcessManager:
    """管理隔离的 Playwright 进程"""
    
    def __init__(self, max_processes=5):
        self.max_processes = max_processes
        self.processes = {}  # session_id -> Process
        self.lock = threading.Lock()
    
    def create_session(self, session_id):
        """创建一个新的隔离 Playwright 进程"""
        with self.lock:
            # 清理过期进程
            self._cleanup_expired_sessions()
            
            # 检查是否超出最大进程数
            if len(self.processes) >= self.max_processes:
                raise RuntimeError(f"已达最大进程数 ({self.max_processes})")
            
            # 创建进程
            cmd = [sys.executable, "-m", "playwright_worker", session_id]
            process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            self.processes[session_id] = {
                "process": process,
                "last_active": time.time()
            }
            
            return True
    
    def execute_command(self, session_id, command):
        """在指定会话中执行命令"""
        if session_id not in self.processes:
            raise ValueError(f"会话 {session_id} 不存在")
        
        session = self.processes[session_id]
        process = session["process"]
        
        # 发送命令到进程
        process.stdin.write(json.dumps(command) + "\n")
        process.stdin.flush()
        
        # 读取响应
        response = process.stdout.readline()
        
        # 更新活动时间
        session["last_active"] = time.time()
        
        return json.loads(response)
```

**安全考量**:
- 每个会话在独立进程中运行，确保完全隔离
- 资源限制和超时机制防止资源滥用
- 会话自动过期和清理

### Google 服务 MCP 集成

为多个 Google 服务开发了 MCP 集成：Gmail, Google Calendar, Google Sheets, Google Drive。

**PR #658**: 修复 Google Calendar 的线程安全 HTTP 请求问题。

**修复重点**:
```python
class ThreadSafeGoogleClient:
    """线程安全的 Google API 客户端"""
    
    def __init__(self, credentials):
        self.credentials = credentials
        self.http_clients = {}  # 每线程一个客户端
        self.lock = threading.RLock()
    
    def get_client(self):
        """获取当前线程的 HTTP 客户端"""
        thread_id = threading.get_ident()
        
        with self.lock:
            if thread_id not in self.http_clients:
                # 为当前线程创建新的 HTTP 客户端
                http = httplib2.Http()
                self.credentials.authorize(http)
                self.http_clients[thread_id] = http
            
            return self.http_clients[thread_id]
    
    def request(self, *args, **kwargs):
        """执行线程安全的 HTTP 请求"""
        client = self.get_client()
        return client.request(*args, **kwargs)
```

**其他重要贡献**:
- **PR #644/640**: 添加联系人搜索功能到 Gmail 和 Google Calendar
- **PR #649/650**: 修复 Google Sheets 的 Dockerfile 和依赖问题

### OAuth 集成框架

**PR #336**: 为自托管 MCP 添加 OAuth 支持。

**架构设计**:
- 统一的 OAuth 流程处理器
- 支持多种授权流程 (授权码、PKCE、客户端凭证)
- 令牌自动刷新和管理
- 安全的凭证存储

```python
class OAuthManager:
    """OAuth认证管理器"""
    
    def __init__(self, config_path):
        self.config = self._load_config(config_path)
        self.tokens = {}
        self._load_tokens()
    
    def get_authorization_url(self, service, redirect_uri, state=None):
        """获取授权URL"""
        service_config = self.config.get(service)
        if not service_config:
            raise ValueError(f"未知服务: {service}")
        
        auth_url = service_config["auth_url"]
        client_id = service_config["client_id"]
        
        params = {
            "client_id": client_id,
            "redirect_uri": redirect_uri,
            "response_type": "code",
            "scope": service_config["scopes"],
        }
        
        if state:
            params["state"] = state
            
        return f"{auth_url}?{urlencode(params)}"
    
    def exchange_code(self, service, code, redirect_uri):
        """用授权码换取访问令牌"""
        service_config = self.config.get(service)
        if not service_config:
            raise ValueError(f"未知服务: {service}")
        
        token_url = service_config["token_url"]
        client_id = service_config["client_id"]
        client_secret = service_config["client_secret"]
        
        data = {
            "client_id": client_id,
            "client_secret": client_secret,
            "code": code,
            "redirect_uri": redirect_uri,
            "grant_type": "authorization_code"
        }
        
        response = requests.post(token_url, data=data)
        if response.status_code != 200:
            raise RuntimeError(f"获取令牌失败: {response.text}")
        
        token_data = response.json()
        self.tokens[service] = {
            "access_token": token_data["access_token"],
            "refresh_token": token_data.get("refresh_token"),
            "expires_at": time.time() + token_data["expires_in"]
        }
        
        self._save_tokens()
        return self.tokens[service]
```

## 3. 个人 MCP 工具开发

### rss-mcp

为 AI 代理开发的 RSS 服务工具，能够订阅、解析和过滤 RSS 源。

**主要功能**:
- 管理多个 RSS 源
- 按关键词过滤内容
- 内容摘要生成
- 历史条目管理

**代码示例 - RSS 解析器**:
```python
import feedparser
import hashlib
from datetime import datetime
import pytz
import re
from typing import Dict, List, Optional

class RssParser:
    """RSS源解析器"""
    
    def parse_feed(self, url: str) -> Dict:
        """解析RSS源，返回规范化的条目列表"""
        feed = feedparser.parse(url)
        
        result = {
            "title": feed.feed.get("title", ""),
            "link": feed.feed.get("link", ""),
            "description": feed.feed.get("description", ""),
            "entries": []
        }
        
        for entry in feed.entries:
            # 提取日期
            published = entry.get("published_parsed") or entry.get("updated_parsed")
            if published:
                dt = datetime(*published[:6], tzinfo=pytz.UTC)
                published_str = dt.isoformat()
            else:
                published_str = None
                
            # 清理内容
            content = entry.get("description", "") or entry.get("summary", "")
            content = self._clean_html(content)
                
            # 创建条目
            entry_data = {
                "id": entry.get("id") or self._generate_id(entry),
                "title": entry.get("title", ""),
                "link": entry.get("link", ""),
                "published": published_str,
                "content": content,
                "author": entry.get("author", "")
            }
            
            result["entries"].append(entry_data)
            
        return result
    
    def _clean_html(self, html: str) -> str:
        """清理HTML标签，保留纯文本"""
        if not html:
            return ""
        # 移除HTML标签
        text = re.sub(r'<[^>]+>', ' ', html)
        # 规范化空白
        text = re.sub(r'\s+', ' ', text).strip()
        return text
    
    def _generate_id(self, entry) -> str:
        """为没有ID的条目生成唯一标识"""
        content = f"{entry.get('title', '')}{entry.get('link', '')}"
        return hashlib.md5(content.encode()).hexdigest()
```

### video_viewer_mcp

为 AI 代理提供视频信息提取和观看能力的 MCP 工具。

**主要功能**:
- 提取视频元数据 (标题、描述、时长等)
- 分析视频帧和场景
- 生成视频内容摘要
- 支持多种视频源 (YouTube, Bilibili, 本地文件)

## 4. 为 MCP 协议和工具创建文档

**PR #833**: 为多个 MCP 服务添加文档，包括 PayPal, Sentry, Netlify, HuggingFace 和 Honeycomb。

**PR #836**: 添加 Azure AD OAuth 指南，帮助用户设置 Microsoft 服务认证。

**文档创作重点**:
- 清晰的安装和配置步骤
- 全面的 API 端点描述
- 代码示例和常见用例
- 故障排除指南

## 🎯 总结与技能展示

### 核心技能
- 深入理解 MCP 协议和 AI 代理系统架构
- 熟练的 API 集成和 OAuth 认证实现
- 高并发和多进程系统设计经验
- 跨平台工具开发能力

### 行业影响
- 为 MCP 协议核心实现贡献关键功能
- 开发 20+ 个企业服务集成
- 创建个人 MCP 工具扩展生态系统
- 提供全面技术文档促进社区采用

---

**文件版本**: v1.0  
**最后更新**: 2026-02-04

