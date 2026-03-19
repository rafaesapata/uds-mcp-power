---
inclusion: auto
---

# UDS MCP Server — Guia de Uso

## Quando usar cada tool

| Intenção | Tool | Tipo |
|---|---|---|
| Padrões de código, code review, arquitetura, segurança, performance | `uds_code_analysis` | static-data |
| Padrões de projeto, CI/CD, documentação, error handling, logging, Docker, AWS | `uds_dev_standards` | static-data |
| Layout, UI, componentes, frontend, mobile, Atomic Design, acessibilidade | `uds_layout_standards` | static-data |
| GitLab, branches, proteção, GitFlow, SonarQube | `uds_gitlab_standards` | static-data |
| Regras de proibição de dados mocados/fake | `uds_no_mock_data` | static-data |
| Regras de execução autônoma | `uds_autonomous_mode` | static-data |
| Otimização de tokens e contexto | `uds_token_optimization` | static-data |
| Estratégia de testes, cobertura, pirâmide | `test_strategy_guide` | bedrock-prompt |
| Quality gates de teste, métricas obrigatórias | `test_quality_gates` | static-data |
| Checklist de code review para testes | `test_code_review_checklist` | bedrock-prompt |
| Auditoria profunda de código (7 passes, Claude Opus) | `code_auditor` | bedrock-prompt |
| Revisão técnica detalhada de feature | `feature_review` | bedrock-prompt |
| Bugs em sistemas distribuídos, race conditions, idempotência | `distributed_system_bug_hunter` | bedrock-prompt |
| Documentação estruturada de conhecimento | `knowledge_documentation` | bedrock-prompt |
| Health check do MCP server | `mcp_health_check` | health-check |
| Testar conectividade MCP | `mcp_echo` | echo |
| Informações AWS do ambiente | `mcp_aws_info` | aws-info |
| Port forwarding SSM para EC2 | `ssm_session_port_forwarding` | lambda-invoke |

## Tools Bedrock com campo `codebase` (OBRIGATÓRIO)

`code_auditor`, `feature_review`, `distributed_system_bug_hunter` e `knowledge_documentation` são tools Bedrock — NÃO têm acesso ao filesystem.

Antes de chamar:
1. Ler os arquivos relevantes do projeto
2. Concatenar no formato `// === arquivo: path ===\n<conteúdo>`
3. Passar no campo `codebase` (limite ~50KB)

### Parâmetros por tool

**code_auditor**: `codebase` (string), `auditLevel` ("quick" | "standard" | "deep"), `language` (string)
**feature_review**: `codebase` (string), `feature_description` (string), `language` (string)
**distributed_system_bug_hunter**: `codebase` (string), `system_description` (string), `language` (string)
**knowledge_documentation**: `codebase` (string), `topic` (string), `language` (string)

## Tools de Padrões UDS — Parâmetros

**uds_code_analysis**: `analysis_type` ("code-review" | "architecture" | "security" | "performance" | "testing" | "all"), `language` (string, default "general")
**uds_dev_standards**: `topic` ("ci-cd" | "documentation" | "error-handling" | "logging" | "docker" | "aws" | "all")
**uds_layout_standards**: `category` ("frontend" | "mobile" | "api-response" | "all"), `framework` ("react" | "react-native" | "general")
**uds_gitlab_standards**: `topic` ("gitflow" | "branch-protection" | "sonarqube" | "all")
**uds_no_mock_data**: `topic` ("rules" | "exceptions" | "all")
**uds_autonomous_mode**: `topic` ("rules" | "all")
**uds_token_optimization**: `topic` ("rules" | "all")

## Tools de Testes — Parâmetros

**test_strategy_guide**: `project_type` (string), `language` (string), `framework` (string)
**test_quality_gates**: `topic` ("metrics" | "coverage" | "all")
**test_code_review_checklist**: `codebase` (string), `language` (string)
