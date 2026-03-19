#!/bin/bash
# UDS MCP Server - Setup Script (OAuth)
# Opens browser for authentication and receives API key via local callback
#
# Usage:
#   bash setup.sh              # OAuth flow (opens browser)
#   bash setup.sh --legacy     # Legacy flow (email/password in terminal)

set -e

API_URL="https://api.mcp.udstec.io"
APP_URL="https://app.mcp.udstec.io"
CALLBACK_PORT=19876
STATE=$(openssl rand -hex 16 2>/dev/null || date +%s | shasum | head -c 32)

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   UDS MCP Server - Configuração Inicial  ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Check for legacy mode
if [ "$1" = "--legacy" ]; then
  shift
  LOGIN="${1:-${UDS_LOGIN:-}}"
  PASSWORD="${2:-${UDS_PASSWORD:-}}"

  if [ -z "$LOGIN" ] || [ -z "$PASSWORD" ]; then
    if [ -t 0 ]; then
      echo "Autentique com suas credenciais do backoffice UDS."
      echo ""
      read -p "E-mail: " LOGIN
      read -s -p "Senha: " PASSWORD
      echo ""
    else
      echo "❌ Erro: Credenciais não fornecidas."
      echo "  bash setup.sh --legacy <email> <senha>"
      exit 1
    fi
  fi

  echo ""
  echo "Autenticando..."

  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/setup-key" \
    -H "Content-Type: application/json" \
    -d "{\"login\":\"$LOGIN\",\"password\":\"$PASSWORD\"}")

  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | sed '$d')

  if [ "$HTTP_CODE" = "201" ]; then
    API_KEY=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['apiKey'])" 2>/dev/null || \
              echo "$BODY" | grep -o '"apiKey":"[^"]*"' | cut -d'"' -f4)
    KEY_NAME=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['keyName'])" 2>/dev/null || echo "")
    USER_NAME=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['userName'])" 2>/dev/null || echo "")

    echo "✅ Autenticado como: $USER_NAME"
    echo "✅ API Key criada: $KEY_NAME"
  elif [ "$HTTP_CODE" = "401" ]; then
    echo "❌ Credenciais inválidas."
    exit 1
  elif [ "$HTTP_CODE" = "403" ]; then
    echo "❌ Conta requer MFA. Use: bash setup.sh (sem --legacy)"
    exit 1
  else
    ERROR=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error',{}).get('message','Erro desconhecido'))" 2>/dev/null || echo "Erro desconhecido")
    echo "❌ Erro: $ERROR (HTTP $HTTP_CODE)"
    exit 1
  fi
else
  # ===== OAuth Flow =====
  REDIRECT_URI="http://localhost:${CALLBACK_PORT}/callback"
  AUTH_URL="${APP_URL}/authorize?redirect_uri=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${REDIRECT_URI}'))" 2>/dev/null || echo "${REDIRECT_URI}")&state=${STATE}"

  echo "Abrindo navegador para autenticação..."
  echo ""

  # Open browser
  if command -v open &> /dev/null; then
    open "$AUTH_URL"
  elif command -v xdg-open &> /dev/null; then
    xdg-open "$AUTH_URL"
  elif command -v wslview &> /dev/null; then
    wslview "$AUTH_URL"
  else
    echo "Abra manualmente no navegador:"
    echo "  $AUTH_URL"
  fi

  echo "Aguardando autenticação no navegador..."
  echo "(Pressione Ctrl+C para cancelar)"
  echo ""

  # Start temporary HTTP server to receive callback
  # Uses Python's http.server for portability
  CALLBACK_RESULT=$(python3 -c "
import http.server
import urllib.parse
import json
import sys

class CallbackHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)

        if parsed.path != '/callback':
            self.send_response(404)
            self.end_headers()
            return

        code = params.get('code', [None])[0]
        state = params.get('state', [None])[0]
        error = params.get('error', [None])[0]

        if error:
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<html><body><h2>Erro</h2><p>Autenticacao falhou. Feche esta janela.</p></body></html>')
            print(json.dumps({'error': error}), file=sys.stderr)
            raise SystemExit(1)

        if not code:
            self.send_response(400)
            self.end_headers()
            return

        # Send success page
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        html = '''<!DOCTYPE html>
<html><head><style>
body{font-family:-apple-system,sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f8fafc}
.card{text-align:center;padding:3rem;border-radius:1rem;background:white;box-shadow:0 4px 24px rgba(0,0,0,.08)}
.icon{font-size:3rem;margin-bottom:1rem}
h2{color:#0f172a;margin:0 0 .5rem}
p{color:#64748b;margin:0}
</style></head><body>
<div class=\"card\"><div class=\"icon\">✅</div><h2>Autorizado!</h2><p>Volte ao terminal. Pode fechar esta janela.</p></div>
</body></html>'''
        self.wfile.write(html.encode())

        # Output code to stdout for the shell script
        print(json.dumps({'code': code, 'state': state}))
        raise SystemExit(0)

    def log_message(self, format, *args):
        pass  # Suppress HTTP logs

server = http.server.HTTPServer(('127.0.0.1', ${CALLBACK_PORT}), CallbackHandler)
server.timeout = 300  # 5 minute timeout
try:
    server.handle_request()
except SystemExit as e:
    if e.code != 0:
        sys.exit(1)
" 2>&1)

  if [ $? -ne 0 ]; then
    echo "❌ Autenticação cancelada ou falhou."
    exit 1
  fi

  # Extract code from callback result
  AUTH_CODE=$(echo "$CALLBACK_RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin)['code'])" 2>/dev/null)

  if [ -z "$AUTH_CODE" ]; then
    echo "❌ Falha ao receber código de autorização."
    exit 1
  fi

  echo "Código recebido. Trocando por API key..."

  # Exchange code for API key
  RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/auth/oauth/token" \
    -H "Content-Type: application/json" \
    -d "{\"code\":\"$AUTH_CODE\"}")

  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | sed '$d')

  if [ "$HTTP_CODE" != "200" ]; then
    ERROR=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error',{}).get('message','Erro desconhecido'))" 2>/dev/null || echo "Erro desconhecido")
    echo "❌ Erro ao trocar código: $ERROR (HTTP $HTTP_CODE)"
    exit 1
  fi

  API_KEY=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['apiKey'])" 2>/dev/null)
  KEY_NAME=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['keyName'])" 2>/dev/null || echo "")
  USER_NAME=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['userName'])" 2>/dev/null || echo "")

  echo "✅ Autenticado como: $USER_NAME"
  echo "✅ API Key criada: $KEY_NAME"
fi

# ===== Save API Key =====
echo ""
export MCP_API_KEY="$API_KEY"

# Save to shell profile
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
  SHELL_RC="$HOME/.bash_profile"
fi

if [ -n "$SHELL_RC" ]; then
  grep -v "^export MCP_API_KEY=" "$SHELL_RC" > "$SHELL_RC.tmp" 2>/dev/null || true
  mv "$SHELL_RC.tmp" "$SHELL_RC"
  echo "export MCP_API_KEY=\"$API_KEY\"" >> "$SHELL_RC"
  echo "✅ MCP_API_KEY salva em $SHELL_RC"
fi

# Also save to launchctl for macOS GUI apps (like Kiro)
if command -v launchctl &> /dev/null; then
  launchctl setenv MCP_API_KEY "$API_KEY" 2>/dev/null || true
  echo "✅ MCP_API_KEY configurada via launchctl (apps GUI)"
fi

# ===== Update Kiro MCP config with API key header =====
KIRO_MCP_CONFIG="$HOME/.kiro/settings/mcp.json"

if [ -f "$KIRO_MCP_CONFIG" ]; then
  python3 -c "
import json

config_path = '$KIRO_MCP_CONFIG'
api_key = '$API_KEY'

with open(config_path, 'r') as f:
    config = json.load(f)

# Update power server entry
powers = config.get('powers', {}).get('mcpServers', {})
for key in powers:
    if 'uds' in key and 'server.mcp.udstec.io' in powers[key].get('url', ''):
        powers[key]['headers'] = {'x-api-key': api_key}
        print(f'✅ Header x-api-key adicionado em powers.mcpServers.{key}')
        break

# Also update top-level mcpServers if exists
servers = config.get('mcpServers', {})
for key in servers:
    if 'uds' in key and 'server.mcp.udstec.io' in servers[key].get('url', ''):
        servers[key]['headers'] = {'x-api-key': api_key}
        print(f'✅ Header x-api-key adicionado em mcpServers.{key}')

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
" 2>&1
  echo "✅ Kiro MCP config atualizado em $KIRO_MCP_CONFIG"
else
  echo "⚠️  Arquivo $KIRO_MCP_CONFIG não encontrado. Configure manualmente o header x-api-key."
fi

echo ""
echo "Configuração concluída!"
echo ""
echo "⚠️  Reinicie o Kiro para aplicar a configuração."
echo ""
