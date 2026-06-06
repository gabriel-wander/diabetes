# Diabetes Pro BR

Aplicativo iOS nativo em SwiftUI, offline-first, em português do Brasil, para apoio técnico à decisão clínica em diabetes mellitus com regras locais auditáveis baseadas nos documentos anexados da Diretriz da Sociedade Brasileira de Diabetes (SBD), edição 2025.

> **Aviso obrigatório:** o aplicativo é destinado a médicos e profissionais habilitados. Ele **não substitui julgamento clínico**, não emite prescrição automática definitiva e não substitui a leitura das diretrizes completas, protocolos locais, avaliação presencial, cálculo de risco formal ou encaminhamento quando indicado.

## Estrutura

```text
Package.swift                         # Pacote Swift com biblioteca core, executável app e testes
Sources/DiabetesProBRCore/            # Models, inputs, armazenamento local e regras clínicas
Sources/DiabetesProBRCore/Resources/  # Catálogo JSON versionado das regras auditáveis
Sources/DiabetesProBRApp/             # Telas SwiftUI do MVP e fallback CLI para validação em Linux
docs/sbd/                             # PDFs SBD 2025 anexados
Tests/DiabetesProBRCoreTests/         # Testes unitários das regras críticas
CHECKLIST_SEGURANCA_CLINICA.md        # Checklist de segurança clínica
```

## Módulos do MVP

1. Diagnóstico e rastreamento.
2. Classificação do diabetes.
3. Metas individualizadas.
4. Tratamento do DM2.
5. Insulinoterapia no DM1.
6. Dias de doença no DM1.
7. Técnica segura de insulina.
8. Idoso com diabetes.
9. Pré-diabetes: planejado; exibe “Não implementado nesta versão — consultar diretriz específica”.
10. DHEM/obesidade: planejado; exibe “Não implementado nesta versão — consultar diretriz específica”.

## Fontes locais

Os documentos-base foram organizados em `docs/sbd/`:

- `01_diagnostico_diabetes.pdf`
- `02_classificacao_diabetes.pdf`
- `03_metas_tratamento_diabetes.pdf`
- `04_manejo_dm2.pdf`
- `05_pre_diabetes.pdf`
- `06_obesidade_prevencao_cv.pdf`
- `07_dhem_dm2_pre_diabetes.pdf`
- `08_idoso_com_diabetes.pdf`
- `09_insulinoterapia_dm1.pdf`
- `10_dias_de_doenca_dm1.pdf`
- `11_aplicacao_segura_insulina.pdf`

## Privacidade e arquitetura offline-first

- As regras clínicas rodam localmente no módulo `DiabetesProBRCore` e têm um catálogo auditável em `Sources/DiabetesProBRCore/Resources/clinical_rules_sbd2025.json`.
- Nenhum dado sensível é enviado para servidor.
- Casos podem ser persistidos localmente apenas por ação explícita do usuário, usando `LocalCaseStore.save(..., explicitConsent: true)`.
- Cada resultado inclui classificação, justificativa, recomendação, alertas de segurança, referência do documento-fonte, data e versão da regra.

## Desenvolvimento

Executar testes do motor de regras:

```bash
swift test
```

Validar o produto executável em ambiente sem SwiftUI, carregando o catálogo JSON versionado:

```bash
swift run DiabetesProBRApp
```

No Xcode/iOS, use o produto executável `DiabetesProBRApp` como app SwiftUI. Em Linux, o mesmo alvo usa um fallback CLI apenas para validar build e recursos, porque SwiftUI não está disponível.

## Limitações atuais

- O MVP implementa apenas as regras explicitamente fornecidas no escopo inicial.
- Não há recomendações inventadas além do escopo informado; módulos incompletos retornam mensagem de não implementação.
- Não há integração com prontuário, servidor, prescrição, cálculo formal externo de risco cardiovascular ou bases remotas.
- Gestação é bloqueada em metas/insulina e direciona o usuário a consultar diretriz específica.

## Próximos passos sugeridos

- Criar app target Xcode com assinatura e assets.
- Expandir o catálogo JSON versionado para cobrir todos os parâmetros configuráveis das próximas versões.
- Adicionar formulários completos de entrada para cada módulo, mantendo dados apenas no dispositivo.
- Validar todas as regras com revisão clínica formal antes de uso assistencial.
