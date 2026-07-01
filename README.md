# Meu Dinheiro 💰

App de finanças pessoais **simples** para iPhone, feito em SwiftUI. A ideia é
anotar os gastos e receitas do dia a dia sem ansiedade: a tela inicial mostra
**só** os botões de registrar, e os totais ficam escondidos atrás de um botão
de resumo.

## O que o app faz

- **Tela inicial** minimalista: você escolhe **Receita** ou **Despesa**.
- **Receita**: causa + valor.
- **Despesa**: título + valor + categoria (Transporte, Saúde, Supermercado,
  Saídas, Extras, Férias, Despesas fixas).
- **Resumo** (escondido, no ícone 📊 no topo): saldo do mês, total de gastos,
  gasto por categoria e diferença entre receita e despesa.
- **Meses**: navegue entre meses (◀ ▶), adicione lançamentos em qualquer mês e
  **edite ou exclua** qualquer item (título, valor, categoria e data).
- **Dados salvos só no seu aparelho** (SwiftData), offline, sem cadastro.

## Requisitos

- **Mac** com **Xcode 16 ou superior**.
- iPhone com **iOS 17 ou superior** (ou o simulador do Xcode).

## Como abrir e rodar

1. Abra o arquivo **`MoneyManager.xcodeproj`** no Xcode (duplo clique).
2. No topo, escolha um simulador de iPhone (ex.: *iPhone 16*).
3. Aperte **▶︎** (ou ⌘R). O app abre no simulador.

## Como instalar no seu iPhone

1. Conecte o iPhone no Mac com o cabo.
2. No Xcode, selecione o iPhone como destino (no topo).
3. Vá em **Signing & Capabilities** do alvo *MoneyManager* e, em **Team**,
   selecione sua conta Apple (Apple ID pessoal serve — é grátis).
   - Se aparecer erro de *bundle identifier*, troque
     `com.rniepce.MoneyManager` por algo único, ex.:
     `com.seunome.MeuDinheiro`.
4. Aperte **▶︎** para instalar e abrir no iPhone.
5. Na primeira vez, o iPhone pode pedir para confiar no desenvolvedor:
   **Ajustes → Geral → VPN e Gerenciamento de Dispositivos** → confie no seu
   Apple ID.

> Com Apple ID gratuito, o app expira após ~7 dias e precisa ser reinstalado
> pelo Xcode. Uma conta paga do Apple Developer remove esse limite.

## Estrutura do código

```
MoneyManager/
  MoneyManagerApp.swift        Ponto de entrada + armazenamento local (SwiftData)
  Models/                      Transaction, TransactionType, ExpenseCategory
  Views/                       Home, Editor (criar/editar), Resumo, Lista do mês
  Support/                     Formatação em R$, filtro de mês, campo de valor
  Assets.xcassets/             Ícone e cor de destaque
```

Os arquivos são incluídos automaticamente pelo Xcode (grupo sincronizado), então
adicionar novos arquivos Swift dentro de `MoneyManager/` funciona sem precisar
mexer nas configurações do projeto.
