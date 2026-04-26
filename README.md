<p align="center">
  <img src="https://app.mcp.udstec.io/icon.png" width="120" alt="UDS MCP Power" />
</p>

<h1 align="center">PowerUP UDS</h1>

<p align="center">
  Kiro Power com 20 tools MCP para padrões de código, layout, testes, análise inteligente e Knowledge Base da UDS Tecnologia.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-2.4.0-blue" alt="Version" />
  <img src="https://img.shields.io/badge/tools-20-green" alt="Tools" />
  <img src="https://img.shields.io/badge/platform-Kiro-purple" alt="Platform" />
  <img src="https://img.shields.io/badge/MCP-Model%20Context%20Protocol-orange" alt="MCP" />
</p>

---

## O que é

Um [Kiro Power](https://kiro.dev) que conecta o agente de IA ao MCP Server da UDS Tecnologia, fornecendo:

- Padrões de código, layout e arquitetura da UDS
- Auditoria de código com Claude Opus (7 passes de análise)
- Caça de bugs em sistemas distribuídos
- Busca semântica em documentos internos (Knowledge Base)
- Estratégias de testes e quality gates
- Padrões GitLab, CI/CD, Docker e AWS
- Tracking de atividade do agente

## Instalação

### Via Kiro (recomendado)

1. Abra o Kiro
2. Vá em Powers → Install from file
3. Selecione o arquivo `uds-mcp-power.zip` (disponível em [app.mcp.udstec.io](https://app.mcp.udstec.io))
4. Na primeira interação, o Kiro abre o navegador para autenticação OAuth

### Manual

```bash
git clone https://github.com/rafaesapata/uds-mcp-power.git
cd uds-mcp-power
bash setup.sh
```

Para ambientes sem navegador:
```bash
bash setup.sh --legacy <email> <senha>
```

## Tools Disponíveis (20)

### Padrões UDS
| Tool | Descrição | Tipo |
|------|-----------|------|
| `uds_code_analysis` | Code review, arquitetura, segurança, performance | static-data |
| `uds_dev_standards` | CI/CD, documentação, error handling, Docker, AWS | static-data |
| `uds_layout_standards` | Layout, UI, Atomic Design, acessibilidade | static-data |
| `uds_gitlab_standards` | GitFlow, branches, SonarQube | static-data |
| `uds_no_mock_data` | Regras de proibição de dados mocados | static-data |
| `uds_autonomous_mode` | Regras de execução autônoma | static-data |
| `uds_token_optimization` | Otimização de tokens e contexto | static-data |

### Análise de Código (Bedrock)
| Tool | Descrição | Modelo |
|------|-----------|--------|
| `code_auditor` | Auditoria profunda com 7 passes | Claude Opus |
| `feature_review` | Revisão técnica de feature | Claude Haiku |
| `distributed_system_bug_hunter` | Bugs em sistemas distribuídos | Claude Haiku |
| `knowledge_documentation` | Documentação estruturada | Claude Haiku |

### Testes
| Tool | Descrição | Tipo |
|------|-----------|------|
| `test_strategy_guide` | Estratégia de testes | bedrock-prompt |
| `test_quality_gates` | Métricas obrigatórias | static-data |
| `test_code_review_checklist` | Checklist de review | bedrock-prompt |

### Knowledge Base
| Tool | Descrição | Tipo |
|------|-----------|------|
| `knowledge_search` | Busca semântica em documentos internos | bedrock-knowledge-base |

### Activity Tracking
| Tool | Descrição | Tipo |
|------|-----------|------|
| `report_activity` | Registra atividades do agente | activity-log |

### Utilitários
| Tool | Descrição | Tipo |
|------|-----------|------|
| `mcp_health_check` | Status do servidor | health-check |
| `mcp_echo` | Teste de conectividade | echo |
| `mcp_aws_info` | Informações do ambiente AWS | aws-info |
| `get_steering_updates` | Guia atualizado de tools e parâmetros | http-proxy |

## Auto-Setup

O Power inclui um steering de auto-setup que, na primeira interação de cada sessão, verifica e cria automaticamente no workspace:

**Steerings** (`.kiro/steering/`):
- `autonomous.md` — Modo autônomo
- `no_mock_data.md` — Proibição de dados mocados
- `token_optimization.md` — Otimização de tokens
- `mcp-tools-guide.md` — Guia de mapeamento intenção → tool

**Hooks** (`.kiro/hooks/`):
- `steering-auto-update` — Atualiza lista de tools a cada mensagem
- `uds-knowledge-search` — Busca na KB quando relevante
- `uds-activity-tool-write` — Tracking de edições
- `uds-activity-session-end` — Resumo de sessão
- `uds-code-standards` — Verificação de padrões ao salvar (desabilitado por padrão)
- `uds-pre-write-review` — Review antes de escrever (desabilitado por padrão)

## Tools Bedrock — Campo `codebase`

`code_auditor`, `feature_review`, `distributed_system_bug_hunter` e `knowledge_documentation` são tools Bedrock que NÃO têm acesso ao filesystem. O agente precisa:

1. Ler os arquivos relevantes do projeto
2. Concatenar no formato `// === arquivo: path ===\n<conteúdo>`
3. Passar no campo `codebase` (limite ~50KB)

## Arquitetura

```
uds-mcp-power/
├── POWER.md              # Documentação do Power (lida pelo Kiro)
├── README.md             # Este arquivo
├── power.json            # Metadados (nome, versão, keywords)
├── mcp.json              # Configuração do MCP server
├── setup.sh              # Setup OAuth + instalação manual
├── icon.png              # Ícone do Power
└── steering/
    ├── uds-standards.md  # Guia de uso com tabela de tools e parâmetros
    └── auto-setup.md     # Auto-instalação de hooks e steerings
```

## URLs

| Serviço | URL |
|---------|-----|
| MCP Endpoint | `https://server.mcp.udstec.io/mcp` |
| Admin Panel | [app.mcp.udstec.io](https://app.mcp.udstec.io) |
| Admin API | `https://api.mcp.udstec.io` |

## Autenticação

O Power usa OAuth 2.1 nativo. Na primeira utilização:

1. O Kiro abre o navegador automaticamente
2. Você faz login com suas credenciais UDS
3. Uma API key é gerada e salva automaticamente
4. O header `x-api-key` é configurado no `mcp.json` do Kiro

A API key é salva em:
- Variável de ambiente `MCP_API_KEY`
- Shell profile (`~/.zshrc` ou `~/.bashrc`)
- `launchctl` (macOS, para apps GUI)
- `~/.kiro/settings/mcp.json`

## Troubleshooting

| Problema | Solução |
|----------|---------|
| 403 Forbidden | Verifique `echo $MCP_API_KEY` e reinicie o Kiro |
| Timeout em tools Bedrock | Normal — podem demorar até 170s, streaming mantém conexão |
| Power não encontra POWER.md | Reinstale o Power a partir do zip atualizado |
| Hooks não instalados | Inicie uma conversa — o auto-setup cria na primeira interação |

## Licença

Uso interno UDS Tecnologia.

---

<p align="center">
  Feito com ☕ pela <a href="https://uds.com.br">UDS Tecnologia</a>
</p>
