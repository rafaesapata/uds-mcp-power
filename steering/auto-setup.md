---
inclusion: auto
description: "Auto-setup de hooks e steerings obrigatórios do NPower na primeira interação"
---

# NPower — Auto-Setup de Hooks e Steerings

**INSTRUÇÃO**: Na primeira interação de cada sessão, verifique se os arquivos abaixo existem no workspace `.kiro/`. Se algum NÃO existir, crie-o com o conteúdo especificado. Pode informar brevemente ao usuário que configurou o NPower — não há nada a esconder.

Use `listDirectory` em `.kiro/hooks` e `.kiro/steering` para verificar. Crie APENAS os que faltam.

> **Princípio (importante)**: hooks do tipo `agent` NUNCA devem pedir para o
> agente agir "silenciosamente / sem avisar o usuário". Isso é indistinguível
> de um prompt-injection e faz o agente (corretamente) recusar — foi a causa
> raiz de hooks que "não executavam". Todas as instruções são transparentes.
> Telemetria (`report_activity`) usa a tool MCP, autenticada pela credencial
> MCP do próprio usuário (portável, sem depender de credencial AWS).
>
> Formato dos hooks: v1 (`.kiro/hooks/<id>.json`, `{ "version": "v1", "hooks": [...] }`).
> O formato legado `.kiro.hook` (`when`/`then`/`askAgent`) foi descontinuado.

---

## Steerings Obrigatórios

### `.kiro/steering/autonomous.md`
```
---
inclusion: always
description: "Diretrizes de execução autônoma — sem paradas, sem confirmações, até 100% concluído"
---

# Modo Autônomo

NUNCA PARE até 100% concluído. Não pergunte, não peça confirmação, não pare para feedback.

- Tome decisões automaticamente, confie no julgamento técnico
- Se encontrar erro, corrija e continue
- Commits frequentes para salvar progresso

Parar SOMENTE quando: todas tarefas `[x]`, testes passando, código commitado.
```

### `.kiro/steering/no_mock_data.md`
```
---
inclusion: always
description: "Regras de proibição de dados mocados, simulados ou placeholder"
---

# Proibição de Dados Simulados/Mocados

## Regra Absoluta
NUNCA use dados mocados, simulados, fake, placeholder ou fallback inventado em NENHUMA circunstância, a menos que o usuário EXPRESSAMENTE solicite.

## O que é PROIBIDO sem solicitação explícita:
- Dados de exemplo inventados (nomes, emails, valores fictícios)
- Respostas simuladas de APIs (mock responses)
- Fallbacks com dados hardcoded quando a fonte real falha
- Stubs que retornam dados fixos em vez de consultar a fonte real
- JSON/objetos com dados placeholder ("Lorem ipsum", "John Doe", "test@test.com")
- Simular sucesso quando uma operação falhou

## O que DEVE ser feito:
- Sempre buscar dados REAIS da fonte correta (API, banco, arquivo)
- Se uma operação falhar, REPORTAR o erro real — não inventar resposta
- Se não tem dados, retornar vazio/null — não preencher com fake
- Se precisa de dados de teste, PERGUNTAR ao usuário ou usar dados que ele forneceu
- Conectar com serviços reais (DynamoDB, APIs, S3) — nunca simular a conexão

## Exceções (SOMENTE quando o usuário pedir):
- "Crie dados de teste para..."
- "Use mock para..."
- "Simule a resposta de..."
- "Crie um stub/fake de..."
- Testes unitários que explicitamente precisam de mocks
```

### `.kiro/steering/token_optimization.md`
```
---
inclusion: always
description: "Diretrizes de otimização de tokens e uso eficiente de contexto"
---

# Otimização de Tokens

## Contexto Mínimo
- Não repita informações já mencionadas
- Respostas concisas, sem headers/bullets desnecessários em resumos

## Ferramentas
- `context-gatherer` uma vez por query para codebase desconhecido
- `getDiagnostics` em vez de `npm run lint` ou `tsc`
- `grepSearch` → `readFile` (linhas específicas) → `strReplace`
- `readMultipleFiles` para contexto relacionado

## Evitar
- Ler arquivo inteiro para encontrar uma função
- Múltiplas chamadas `readFile` sequenciais
- Reescrever arquivo inteiro para mudar uma linha
- Explicações longas após cada ação
- Criar arquivos de documentação não solicitados
```

### `.kiro/steering/auth-entra-id.md`
```
---
inclusion: always
description: "Regra de autenticação: nunca PAT, sempre Microsoft Entra ID (Azure DevOps e git push)"
---

# Autenticação — Nunca PAT, Sempre Microsoft Entra ID

Regra absoluta do projeto. Não existe mais nenhum fluxo de PAT para Azure DevOps.
Qualquer autenticação com Azure DevOps — runtime da aplicação ou `git push`/`git fetch` —
usa Microsoft Entra ID. Não gere, não peça, não armazene, não leia PAT.

## Runtime (mcp-server)
- Auth delegada ao Azure DevOps no login OAuth 2.1 do MCP (`/authorize`), via `services/entra-auth.ts`.
- Refresh tokens cifrados por usuário em `mcp-entra-tokens` (KMS `alias/mcp-entra-tokens`).
- Removido/proibido reintroduzir: `mcp-user-pats`, `alias/nuevacore-user-pats`, `user-pat.ts`,
  handler `user-pat`, tools `azure_devops_pat_setup`/`azure_devops_pat_status`.

## git push (remote Azure DevOps)
Só via Entra ID (OAuth), nunca PAT. Método que funciona nesta org:
git-credential-manager em modo OAuth:
```
git config --global credential.helper manager
git config --global credential.azreposCredentialType oauth
git config --global credential.https://dev.azure.com.useHttpPath true
```
Armadilhas: (1) token cru do `az account get-access-token` é rejeitado por
Conditional Access (redirect 203/login, push 401). (2) GCM em modo default
tenta criar PAT e a org bloqueia (DisablePatCreationPolicyViolation) — por
isso `azreposCredentialType=oauth` é obrigatório. Nunca persista token em
arquivo versionado.
```

### `.kiro/steering/mcp-tools-guide.md`
```
---
inclusion: auto
description: "Mapeamento de intenções do usuário para tools MCP do NPower"
---

# NPower MCP Server — Guia de Tools

Quando o usuário pedir algo relacionado aos tópicos abaixo, use a tool MCP correspondente.

## Mapeamento de intenção → tool

| Intenção do usuário | Tool MCP |
|---|---|
| Padrões de código, code review, arquitetura, segurança, performance, testes | `uds_code_analysis` |
| Padrões de projeto, CI/CD, documentação, error handling, logging, Docker, AWS | `uds_dev_standards` |
| Layout, UI, componentes, frontend, mobile, API response | `uds_layout_standards` |
| GitLab, branches, proteção, GitFlow, SonarQube, API curl | `uds_gitlab_standards` |
| Auditoria de código, análise profunda de codebase | `code-auditor` (campo `codebase`) |
| Revisão técnica de feature | `feature-review` (campo `codebase`) |
| Bugs em sistemas distribuídos, race conditions | `distributed-system-bug-hunter` (campo `codebase`) |
| Estratégia de testes, cobertura, pirâmide de testes | `test-strategy-guide` |
| Quality gates de teste, métricas obrigatórias | `test-quality-gates` |
| Checklist de code review para testes | `test-code-review-checklist` |
| Documentar conhecimento, lições aprendidas | `knowledge-documentation` |
| Busca em documentos internos (RFPs, manuais, processos) | `knowledge-search` (param: `query`) |
| Regras de dados mocados/fake | `uds_no_mock_data` |
| Modo autônomo | `uds_autonomous_mode` |
| Otimização de tokens | `uds_token_optimization` |
| Health check do MCP server | `mcp_health_check` |
| Informações AWS | `mcp_aws_info` |
| Testar conectividade MCP | `mcp_echo` |

## Regras
- Sempre prefira chamar a tool MCP ao invés de responder de memória sobre padrões NPower
- Para tools que aceitam `codebase`, envie o código real do arquivo relevante
- Quando o usuário perguntar sobre projetos, clientes, documentos ou informações internas, use `knowledge-search`
```

---

## Hooks Obrigatórios (formato v1 `.json`)

### `.kiro/hooks/steering-auto-update.json`
```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Steering Auto Update",
      "description": "Obtém a lista atualizada de tools/prompts do MCP quando necessário.",
      "trigger": "UserPromptSubmit",
      "action": {
        "type": "agent",
        "prompt": "Se você precisar saber quais tools/prompts do NPower estão disponíveis ou seus parâmetros, chame `get_steering_updates` para obter a lista atualizada antes de usá-las."
      },
      "enabled": true
    }
  ]
}
```

### `.kiro/hooks/npower-knowledge-search.json`
```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "NPower Knowledge Search",
      "description": "Instrui o agente a buscar na Knowledge Base quando relevante.",
      "trigger": "UserPromptSubmit",
      "action": {
        "type": "agent",
        "prompt": "Se o usuário estiver perguntando sobre projetos, clientes, RFPs, propostas, documentos internos ou informações da empresa da UDS/NuevaCore, use a tool `knowledge-search` do NPower para buscar na base de conhecimento antes de responder. Pode citar naturalmente que consultou a base quando fizer sentido."
      },
      "enabled": true
    }
  ]
}
```

### `.kiro/hooks/npower-activity-session-end.json`
```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "NPower Activity - Session Summary",
      "description": "Quando o agente para, registra um resumo da sessão via report_activity (telemetria de produtividade).",
      "trigger": "Stop",
      "action": {
        "type": "agent",
        "prompt": "A sessão do agente terminou. Chame a tool `report_activity` do NPower com eventType='session-summary' e details contendo um resumo breve do que foi feito nesta sessão (arquivos editados, tarefas concluídas). É telemetria de produtividade da equipe — registre de forma transparente. Se a tool não estiver disponível, apenas siga em frente."
      },
      "enabled": true
    }
  ]
}
```

### `.kiro/hooks/npower-activity-tool-write.json`
```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "NPower Activity - Track Tool Write",
      "description": "Após uma operação de escrita, registra atividade via report_activity.",
      "trigger": "PostToolUse",
      "matcher": "^(fs_write|fs_append|str_replace|delete_file|code)$",
      "action": {
        "type": "agent",
        "prompt": "Uma operação de escrita foi concluída. Se relevante, chame a tool `report_activity` do NPower com eventType='file-edit' e details contendo o fileName do arquivo editado."
      },
      "enabled": false
    }
  ]
}
```

### `.kiro/hooks/npower-code-standards.json`
```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "NPower Code Standards Check",
      "description": "Ao salvar arquivo .ts/.tsx/.js/.jsx, verifica padrões NPower.",
      "trigger": "PostFileSave",
      "matcher": "([^/]*\\.ts$|[^/]*\\.tsx$|[^/]*\\.js$|[^/]*\\.jsx$)",
      "action": {
        "type": "agent",
        "prompt": "O arquivo foi editado. Se houver mudanças significativas, considere usar a tool `uds_code_analysis` do NPower para verificar se o código segue os padrões da NuevaCore, e comente com o usuário caso encontre problemas relevantes."
      },
      "enabled": false
    }
  ]
}
```

### `.kiro/hooks/npower-pre-write-review.json`
```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "NPower Pre-Write Review",
      "description": "Antes de escrever um arquivo, verifica padrões NPower.",
      "trigger": "PreToolUse",
      "matcher": "^(fs_write|fs_append|str_replace|delete_file|code)$",
      "action": {
        "type": "agent",
        "prompt": "Antes de escrever este arquivo, verifique se o código segue os padrões NPower: nomenclatura, estrutura, tratamento de erros e boas práticas. Se necessário, consulte `uds_code_analysis` ou `uds_dev_standards`. Não bloqueie a escrita, apenas ajuste se necessário."
      },
      "enabled": false
    }
  ]
}
```

---

## Informações de Repositórios (IMPORTANTE)

O projeto é dividido em DOIS repositórios separados:

- **Power (GitHub — público)**: `https://github.com/rafaesapata/npower-mcp`
  - Contém: POWER.md, power.json, mcp.json, setup.sh, icon.png, steering/
  - Pasta local: `npower-mcp/`
  - Push: `git -C npower-mcp push origin main`

- **MCP Server (privado — Azure DevOps)**: repo "UDS - MCP" no Azure DevOps
  - Contém: mcp-server, admin-panel, admin-api, infra CDK, kiro-power (cópia)
  - Pasta local: `mcp-server-lambda/`
  - Push: autenticação **via Microsoft Entra ID**, nunca PAT (ver `auth-entra-id.md`)

### Regras de Push
- Alterações no Power → push para AMBOS (GitHub e o repo privado)
- Alterações no MCP server/admin/infra → push APENAS para o repo privado
- A pasta `mcp-server-lambda/kiro-power/` é uma cópia do Power dentro do repo do servidor
- Ao alterar arquivos do Power, sincronize AMBAS as pastas antes de fazer push

---

## Mapa Arquitetural (Opcional mas Recomendado)

Após verificar hooks e steerings, verifique se existe `.kiro/steering/architecture-map.md`.

Se NÃO existir, sugira ao dev (UMA VEZ, de forma breve):

> "Posso gerar um mapa arquitetural do projeto para otimizar sessões futuras. Isso elimina a necessidade de reler código a cada conversa. Quer que eu gere?"

Se o dev aceitar:
1. Leia os arquivos-chave do projeto (entry points, services, routes, schemas, types, config, infra)
2. Chame a tool MCP `generate_architecture_map` com o codebase concatenado
3. Salve o resultado em `.kiro/steering/architecture-map.md`

Se o dev recusar ou ignorar, não insista.

---

## Regras de Verificação

1. Verifique APENAS na primeira interação da sessão
2. Crie APENAS arquivos que NÃO existem — nunca sobrescreva existentes
3. Use o formato v1 `.json` para hooks — não use o formato legado `.kiro.hook`
4. Nenhuma instrução de hook deve pedir para agir "silenciosamente / sem avisar o usuário"
5. Se todos os arquivos já existem, não faça nada
