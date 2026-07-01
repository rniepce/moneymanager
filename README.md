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
- **Chat com IA** (💬 no canto da tela inicial): converse em português sobre
  seus dados ("quanto gastei com transporte esse mês?", "onde posso
  economizar?"). Usa a **DeepSeek**.
- **Dados salvos só no seu aparelho** (SwiftData), offline, sem cadastro — exceto
  ao usar o chat com IA (veja abaixo).

## Chat com IA (DeepSeek)

O botão 💬 na tela inicial abre um chat que responde sobre seus lançamentos.

1. Crie uma chave de API em **platform.deepseek.com** (menu *API Keys*).
2. No app, abra o chat e toque na **engrenagem** (Ajustes).
3. Cole a chave e salve. Ela fica guardada com segurança no aparelho (Keychain),
   nunca no código. O modelo padrão é `deepseek-chat` — você pode trocar o id nos
   Ajustes se sua conta usar outro (ex.: um modelo mais novo).

> ⚠️ **Privacidade**: ao usar o chat, seus lançamentos (títulos, valores,
> categorias e datas) são enviados aos servidores da DeepSeek para a IA poder
> responder. O restante do app continua funcionando **só no seu aparelho**.

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
  Models/                      Transaction, TransactionType, ExpenseCategory, ChatMessage
  Views/                       Home, Editor (criar/editar), Resumo, Lista do mês,
                               Chat (IA) e Ajustes
  Support/                     Formatação em R$, filtro de mês, campo de valor,
                               chave no Keychain, contexto e cliente da DeepSeek
  Assets.xcassets/             Ícone e cor de destaque
```

Os arquivos são incluídos automaticamente pelo Xcode (grupo sincronizado), então
adicionar novos arquivos Swift dentro de `MoneyManager/` funciona sem precisar
mexer nas configurações do projeto.
