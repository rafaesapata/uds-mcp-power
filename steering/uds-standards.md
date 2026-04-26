---
inclusion: auto
---

# UDS MCP Server — Guia de Uso

## ⚡ Auto-atualização do Steering

**IMPORTANTE**: No início de cada sessão, chame a tool `get_steering_updates` para obter a lista atualizada de tools, prompts e parâmetros disponíveis. O conteúdo abaixo pode estar desatualizado — a tool sempre retorna a versão mais recente do servidor.

## Repositório
- GitHub: https://github.com/rafaesapata/uds-mcp-power

## Quando usar cada tool

| Intenção | Tool | Tipo |
|---|---|---|
| Padrões de código, code review, arquitetura, segurança, performance | `uds_code_analysis` | static-data |
| Padrões de projeto, CI/CD, documentação, error handling, logging, Docker, AWS | `uds_dev_standards` | static-data |
| Layout, UI, componentes, frontend, mobile, Atomic Design, acessibilidade | `uds_layout_standards` | static-data |
| GitLab, branches, proteção, GitFlow, SonarQube, API curl, IDs de projetos | `uds_gitlab_standards` | static-data |
| Regras de proibição de dados mocados/fake | `uds_no_mock_data` | static-data |
| Regras de execução autônoma | `uds_autonomous_mode` | static-data |
| Otimização de tokens e contexto | `uds_token_optimization` | static-data |
| Estratégia de testes, cobertura, pirâmide | `test_strategy_guide` | bedrock-prompt |
| Quality gates de teste, métricas obrigatórias | `test_quality_gates` | static-data |
| Checklist de code review para testes | `test_code_review_checklist` | bedrock-prompt |
| Auditoria profunda de código (7 passes, Claude Opus) | `code-auditor` | bedrock-prompt |
| Revisão técnica detalhada de feature | `feature-review` | bedrock-prompt |
| Bugs em sistemas distribuídos, race conditions, idempotência | `distributed-system-bug-hunter` | bedrock-prompt |
| Documentação estruturada de conhecimento | `knowledge-documentation` | bedrock-prompt |
| Health check do MCP server | `mcp_health_check` | health-check |
| Testar conectividade MCP | `mcp_echo` | echo |
| Informações AWS do ambiente | `mcp_aws_info` | aws-info |
| Guia de uso atualizado (tools, prompts, parâmetros) | `get_steering_updates` | http-proxy |
| Busca em documentos internos (RFPs, manuais, processos, contratos) | `knowledge-search` | bedrock-knowledge-base |
| Registrar atividade do agente | `report_activity` | activity-log |

## Tools Bedrock com campo `codebase` (OBRIGATÓRIO)

`code-auditor`, `feature-review`, `distributed-system-bug-hunter` e `knowledge-documentation` são tools Bedrock — NÃO têm acesso ao filesystem.

Antes de chamar:
1. Ler os arquivos relevantes do projeto
2. Concatenar no formato `// === arquivo: path ===\n<conteúdo>`
3. Passar no campo `codebase` (limite ~50KB)

### Parâmetros por tool

**code-auditor**: `codebase` (string), `auditLevel` ("quick" | "standard" | "deep"), `language` (string)
**feature-review**: `codebase` (string), `feature_description` (string), `language` (string)
**distributed-system-bug-hunter**: `codebase` (string), `system_description` (string), `language` (string)
**knowledge-documentation**: `codebase` (string), `topic` (string), `language` (string)

## Tools de Padrões UDS — Parâmetros

**uds_code_analysis**: `analysis_type` ("code-review" | "architecture" | "security" | "performance" | "testing" | "all"), `language` (string, default "general")
**uds_dev_standards**: `topic` ("ci-cd" | "documentation" | "error-handling" | "logging" | "docker" | "aws" | "all")
**uds_layout_standards**: `category` ("frontend" | "mobile" | "api-response" | "all"), `framework` ("react" | "react-native" | "general")
**uds_gitlab_standards**: `topic` ("project-structure" | "gitflow" | "branch-protection" | "security" | "authentication" | "sonarqube" | "checklist" | "api" | "all")
**uds_no_mock_data**: `topic` ("rules" | "exceptions" | "all")
**uds_autonomous_mode**: `topic` ("rules" | "all")
**uds_token_optimization**: `topic` ("rules" | "all")

## Tools de Testes — Parâmetros

**test-strategy-guide**: `project_type` (string), `language` (string), `framework` (string)
**test-quality-gates**: `topic` ("metrics" | "coverage" | "all")
**test-code-review-checklist**: `codebase` (string), `language` (string)

## Knowledge Base — Busca em Documentos

**knowledge-search**: `query` (string) — Busca semântica na base de conhecimento. Use quando o usuário perguntar sobre projetos, clientes, RFPs, propostas, documentos internos ou qualquer informação que possa estar em arquivos indexados. Retorna trechos relevantes com resposta gerada por IA.

## Prompts MCP — Auto-discovery

O servidor registra prompts dinâmicos além das tools. Para descobrir prompts disponíveis, use `list_prompts`. Para usar um prompt, chame `get_prompt` com o nome e os argumentos.

Prompts são templates parametrizáveis para guias de estilo, documentação, instruções e padrões de interação. Novos prompts são criados via importação ou admin panel e ficam disponíveis automaticamente.

Quando o agente identificar que a intenção do usuário se encaixa em um template (ex: gerar documentação, aplicar padrão de código, seguir guia), deve verificar `list_prompts` para ver se existe um prompt adequado antes de criar a resposta do zero.
