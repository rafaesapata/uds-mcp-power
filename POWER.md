---
name: "uds-mcp-power"
displayName: "UDS MCP Power"
description: "Padrões de código, layout, testes e análise inteligente da UDS Tecnologia — 20 tools incluindo code auditor com Claude Opus, bug hunter para sistemas distribuídos, Knowledge Base e guias de CI/CD, Docker e AWS"
keywords: ["uds", "padrões", "layout", "código", "análise", "desenvolvimento", "frontend", "backend", "react", "mobile", "segurança", "performance", "testes", "ci-cd", "docker", "aws"]
---

# UDS MCP Power

MCP Server da UDS Tecnologia com padrões de layout, análise de código e desenvolvimento de software.

## Setup Inicial

O power usa OAuth 2.1 nativo — ao instalar e usar pela primeira vez, o Kiro abre automaticamente o navegador para autenticação com suas credenciais UDS. Nenhum setup manual é necessário.

Para ambientes sem navegador (CI, SSH), use o setup legado:
```bash
bash setup.sh --legacy <email> <senha>
```

## Auto-Setup de Hooks e Steerings

O Power inclui um steering de auto-setup (`steering/auto-setup.md`) que instrui o agente a verificar e criar automaticamente os hooks e steerings obrigatórios no workspace `.kiro/` na primeira interação de cada sessão. Isso garante que a instalação seja determinística e consistente, sem depender de execução manual do `setup.sh`.

## Tools Disponíveis (20)

### Padrões UDS (static-data)
- `uds_code_analysis` — Code review, arquitetura, segurança, performance, testes
- `uds_dev_standards` — CI/CD, documentação, error handling, logging, Docker, AWS
- `uds_layout_standards` — Layout, UI, Atomic Design, acessibilidade, responsividade
- `uds_gitlab_standards` — GitFlow, proteção de branches, SonarQube, API curl com IDs de projetos
- `uds_no_mock_data` — Regras de proibição de dados mocados
- `uds_autonomous_mode` — Regras de execução autônoma
- `uds_token_optimization` — Otimização de tokens e contexto

### Testes
- `test-strategy-guide` — Estratégia de testes via Bedrock (bedrock-prompt)
- `test-quality-gates` — Métricas obrigatórias de qualidade (static-data)
- `test-code-review-checklist` — Checklist de review para testes (bedrock-prompt)

### Análise de Código (bedrock-prompt)
- `code-auditor` — Auditoria profunda com metodologia de 7 passes (usa Claude Opus)
- `feature-review` — Revisão técnica detalhada de feature
- `distributed-system-bug-hunter` — Caça bugs em sistemas distribuídos
- `knowledge-documentation` — Gera documentação estruturada de conhecimento

### Knowledge Base
- `knowledge-search` — Busca semântica em documentos internos (RFPs, manuais, processos, contratos)

### Activity Tracking
- `report_activity` — Registra atividades do agente (file-edit, session-summary, etc.)

### Utilitários
- `mcp_health_check` — Status do servidor
- `mcp_echo` — Teste de conectividade
- `mcp_aws_info` — Informações do ambiente AWS
- `get_steering_updates` — Guia de uso atualizado (tools, prompts, parâmetros)

## Tools com campo `codebase`

`code-auditor`, `feature-review` e `distributed-system-bug-hunter` são tools Bedrock — NÃO têm acesso ao filesystem. Antes de chamá-las:

1. Leia os arquivos relevantes do projeto
2. Concatene no formato `// === arquivo: path ===\n<conteúdo>`
3. Passe no campo `codebase` (limite ~50KB)

## URLs
- Admin Panel: https://app.mcp.udstec.io
- MCP Endpoint: https://server.mcp.udstec.io/mcp
- Admin API: https://api.mcp.udstec.io

## Prompts MCP

O servidor MCP também disponibiliza prompts — templates reutilizáveis para interações com LLMs. Prompts são registrados dinamicamente a partir do DynamoDB e podem ser criados via importação ou admin panel.

Para descobrir os prompts disponíveis, use `list_prompts`. Para usar um prompt, chame `get_prompt` com o nome e argumentos necessários.

## Troubleshooting

- **403**: Verifique `echo $MCP_API_KEY` e reinicie o Kiro se necessário
- **Timeout**: Tools Bedrock podem demorar até 170s, streaming mantém conexão viva
- **Logs**: `aws logs tail /aws/lambda/mcp-server --follow`
