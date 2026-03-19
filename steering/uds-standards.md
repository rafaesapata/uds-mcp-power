---
inclusion: auto
---

# UDS MCP Server — Guia Completo

## Mapeamento de intenção → tool

| Intenção do usuário | Tool MCP |
|---|---|
| Padrões de código, code review, arquitetura, segurança, performance, testes | `uds_code_analysis` |
| Padrões de projeto, CI/CD, documentação, error handling, logging, Docker, AWS | `uds_dev_standards` |
| Layout, UI, componentes, frontend, mobile, API response | `uds_layout_standards` |
| GitLab, branches, proteção, GitFlow, SonarQube | `uds_gitlab_standards` |
| Auditoria de código, análise profunda de codebase | `code_auditor` (campo `codebase` obrigatório) |
| Revisão técnica de feature, auditoria de feature | `feature_review` (campo `codebase` obrigatório) |
| Bugs em sistemas distribuídos, race conditions, idempotência | `distributed_system_bug_hunter` (campo `codebase` obrigatório) |
| Estratégia de testes, cobertura, pirâmide de testes | `test_strategy_guide` |
| Quality gates de teste, métricas obrigatórias | `test_quality_gates` |
| Checklist de code review para testes | `test_code_review_checklist` |
| Documentar conhecimento, lições aprendidas | `knowledge_documentation` |
| Regras de dados mocados/fake | `uds_no_mock_data` |
| Modo autônomo, regras de execução contínua | `uds_autonomous_mode` |
| Otimização de tokens, contexto mínimo | `uds_token_optimization` |
| Health check do MCP server | `mcp_health_check` |
| Informações AWS do MCP server | `mcp_aws_info` |
| Testar conectividade MCP | `mcp_echo` |
| Port forwarding SSM para EC2 | `ssm_session_port_forwarding` |

## Tools que aceitam código (Bedrock)

`code_auditor`, `feature_review` e `distributed_system_bug_hunter` NÃO têm acesso ao filesystem. O campo `codebase` deve conter o conteúdo real dos arquivos.

Antes de chamar:
1. Ler os arquivos relevantes do projeto
2. Concatenar no formato `// === arquivo: path ===\n<conteúdo>`
3. Passar no campo `codebase` (limite ~50KB)

## Regras operacionais

- Sempre prefira chamar a tool MCP ao invés de responder de memória sobre padrões UDS
- Valide conformidade com os padrões antes de submeter PRs
- Para auditorias profundas, use `code_auditor` com `auditLevel: "deep"`
- NUNCA use dados mocados/simulados sem solicitação explícita do usuário
- Modo autônomo: não pare, não peça confirmação, tome decisões automaticamente

## GitLab API — Padrão para chamadas curl

NUNCA usar `\` de continuação de linha. Sempre uma única linha.

Token GitLab — extrair do macOS Keychain:
```bash
TOKEN=$(security find-internet-password -s gitlab.udstec.io -w)
```

### IDs dos Projetos GitLab

| Projeto | ID |
|---|---|
| auth | 960 |
| common | 955 |
| customer | 963 |
| payment | 964 |
| gateway | 965 |
| communication | 966 |
| report | 967 |
| jobs | 969 |
| frontend | 986 |
| vehicle | 1022 |
| reservation | 1023 |
| chat | 1024 |
| support | 1025 |

### Exemplos curl (sempre em uma linha)

Criar Merge Request:
```bash
curl -s --request POST --header "PRIVATE-TOKEN: $TOKEN" --header "Content-Type: application/json" -d '{"source_branch":"feature/x","target_branch":"develop","title":"feat: description","remove_source_branch":true}' "https://gitlab.udstec.io/api/v4/projects/PROJECT_ID/merge_requests"
```

Merge automático de MR:
```bash
curl -s --request PUT --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.udstec.io/api/v4/projects/PROJECT_ID/merge_requests/MR_IID/merge"
```

Listar MRs abertos:
```bash
curl -s --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.udstec.io/api/v4/projects/PROJECT_ID/merge_requests?state=opened"
```

Listar branches:
```bash
curl -s --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.udstec.io/api/v4/projects/PROJECT_ID/repository/branches"
```
