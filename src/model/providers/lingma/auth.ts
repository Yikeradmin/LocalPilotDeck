/**
 * Lingma Authentication Handler
 * Login URL: http://25.0.97.48/users/login
 * Token URL: http://25.0.97.48/users/settings/personalAccessToken
 */

import * as fs from 'fs';
import * as path from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const LINGMA_BASE_URL = 'http://25.0.97.48';
const LINGMA_LOGIN_URL = `${LINGMA_BASE_URL}/users/login`;
const LINGMA_TOKEN_URL = `${LINGMA_BASE_URL}/users/settings/personalAccessToken`;
const LINGMA_CONFIG_DIR = path.join(process.env.HOME || '/root', '.pilotdeck');
const LINGMA_TOKEN_FILE = path.join(LINGMA_CONFIG_DIR, 'lingma-token.json');

export interface LingmaTokenInfo {
  token: string;
  savedAt: string;
  userId?: string;
}

export class LingmaAuth {
  private tokenInfo: LingmaTokenInfo | null = null;

  constructor() {
    this.loadToken();
  }

  getLoginInstructions(): string {
    return `
╔══════════════════════════════════════════════════════════════════╗
║                     Lingma 登录指引                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  1. 在浏览器中打开登录页面:                                       ║
║     ${LINGMA_LOGIN_URL}                                         ║
║                                                                  ║
║  2. 使用您的账号登录                                             ║
║                                                                  ║
║  3. 登录后访问 Token 页面:                                       ║
║     ${LINGMA_TOKEN_URL}                                         ║
║                                                                  ║
║  4. 复制 Personal Access Token                                   ║
║                                                                  ║
║  5. 在 PilotDeck 配置中设置:                                     ║
║     model.providers.lingma.apiKey = <your-token>                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
`;
  }

  async openLoginBrowser(): Promise<void> {
    const platform = process.platform;
    let cmd: string;
    if (platform === 'darwin') {
      cmd = `open "${LINGMA_LOGIN_URL}"`;
    } else if (platform === 'win32') {
      cmd = `start "${LINGMA_LOGIN_URL}"`;
    } else {
      cmd = `xdg-open "${LINGMA_LOGIN_URL}" 2>/dev/null || echo "请在浏览器中打开: ${LINGMA_LOGIN_URL}"`;
    }
    try {
      await execAsync(cmd);
    } catch {
      // ignore
    }
  }

  saveToken(token: string, userId?: string): void {
    if (!fs.existsSync(LINGMA_CONFIG_DIR)) {
      fs.mkdirSync(LINGMA_CONFIG_DIR, { recursive: true });
    }
    this.tokenInfo = {
      token,
      savedAt: new Date().toISOString(),
      userId,
    };
    fs.writeFileSync(LINGMA_TOKEN_FILE, JSON.stringify(this.tokenInfo, null, 2), { mode: 0o600 });
  }

  private loadToken(): void {
    if (!fs.existsSync(LINGMA_TOKEN_FILE)) return;
    try {
      const data = fs.readFileSync(LINGMA_TOKEN_FILE, 'utf-8');
      this.tokenInfo = JSON.parse(data) as LingmaTokenInfo;
    } catch {
      // ignore
    }
  }

  getToken(): string | null {
    return this.tokenInfo?.token || null;
  }

  isAuthenticated(): boolean {
    return this.tokenInfo !== null && this.tokenInfo.token.length > 0;
  }

  clearToken(): void {
    if (fs.existsSync(LINGMA_TOKEN_FILE)) {
      fs.unlinkSync(LINGMA_TOKEN_FILE);
    }
    this.tokenInfo = null;
  }

  getTokenInfo(): LingmaTokenInfo | null {
    return this.tokenInfo;
  }
}

export const lingmaAuth = new LingmaAuth();
