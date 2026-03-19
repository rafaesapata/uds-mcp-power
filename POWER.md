# UDS MCP Server

MCP Server da UDS Tecnologia com padrões de layout, análise de código e desenvolvimento de software.

## Setup Inicial

O power usa OAuth 2.1 nativo — ao instalar e usar pela primeira vez, o Kiro abre automaticamente o navegador para autenticação com suas credenciais UDS. Nenhum setup manual é necessário.

Para ambientes sem navegador (CI, SSH), use o setup legado:
```bash
bash setup.sh --legacy <email> <senha>
```

## Tools Disponíveis (18)

### Padrões UDS (static-data)
- `uds_code_analysis` — Code review, arquitetura, segurança, performance, testes
- `uds_dev_standards` — CI/CD, documentação, error handling, logging, Docker, AWS
- `uds_layout_standards` — Layout, UI, Atomic Design, acessibilidade, responsividade
- `uds_gitlab_standards` — GitFlow, proteção de branches, SonarQube
- `uds_no_mock_data` — Regras de proibição de dados mocados
- `uds_autonomous_mode` — Regras de execução autônoma
- `uds_token_optimization` — Otimização de tokens e contexto

### Testes
- `test_strategy_guide` — Estratégia de testes via Bedrock (bedrock-prompt)
- `test_quality_gates` — Métricas obrigatórias de qualidade (static-data)
- `test_code_review_checklist` — Checklist de review para testes (bedrock-prompt)

### Análise de Código (bedrock-prompt)
- `code_auditor` — Auditoria profunda com metodologia de 7 passes (usa Claude Opus)
- `feature_review` — Revisão técnica detalhada de feature
- `distributed_system_bug_hunter` — Caça bugs em sistemas distribuídos
- `knowledge_documentation` — Gera documentação estruturada de conhecimento

### Utilitários
- `mcp_health_check` — Status do servidor
- `mcp_echo` — Teste de conectividade
- `mcp_aws_info` — Informações do ambiente AWS
- `ssm_session_port_forwarding` — Port forwarding via SSM para EC2

## Tools com campo `codebase`

`code_auditor`, `feature_review` e `distributed_system_bug_hunter` são tools Bedrock — NÃO têm acesso ao filesystem. Antes de chamá-las:

1. Leia os arquivos relevantes do projeto
2. Concatene no formato `// === arquivo: path ===\n<conteúdo>`
3. Passe no campo `codebase` (limite ~50KB)

## URLs
- Admin Panel: https://app.mcp.udstec.io
- MCP Endpoint: https://server.mcp.udstec.io/mcp
- Admin API: https://api.mcp.udstec.io

## Troubleshooting

- **403**: Verifique `echo $MCP_API_KEY` e reinicie o Kiro se necessário
- **Timeout**: Tools Bedrock podem demorar até 170s, streaming mantém conexão viva
- **Logs**: `aws logs tail /aws/lambda/mcp-server --follow`
