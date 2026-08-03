# Escrita Criativa — plano do aplicativo

Aplicativo local para **construir cursos de escrita criativa** a partir de uma
base de conhecimento própria, com apoio de LLM (DeepSeek V4).

> **Status**: documento de planejamento. Nada foi implementado ainda.
> **Destino final**: [`rniepce/escritacriativa`](https://github.com/rniepce/escritacriativa).
> O plano está parado em `rniepce/moneymanager` (branch
> `claude/creative-writing-course-app-0yrbrh`, pasta `escritacriativa/`) porque
> esta sessão ainda não recebeu acesso ao repositório novo. O conteúdo desta
> pasta espelha a raiz do repositório de destino: transplantar é copiar e colar.

---

## 1. O problema

Preparar um curso de escrita criativa hoje significa: reler livros de teoria e
manuais, garimpar trechos literários que sirvam de exemplo, lembrar de
exercícios que funcionaram em turmas anteriores e encaixar tudo num número fixo
de encontros, sem repetir assunto e sem deixar buraco na progressão.

O trabalho difícil não é escrever o roteiro da aula — é **lembrar do que você já
sabe** e **distribuir isso bem no tempo disponível**.

O app ataca exatamente esses dois pontos.

## 2. O que o app faz

Três etapas, na ordem em que você as usa:

### Etapa 1 — Receber conteúdo (ingestão)

Você joga material dentro do app: PDFs, EPUBs, seus arquivos `.docx`/`.md`/`.txt`
com anotações e aulas antigas, obras literárias que servem de exemplo, e
áudio/vídeo de palestras (transcritos automaticamente).

O app extrai o texto preservando a estrutura (capítulos, seções, páginas) e
guarda de onde veio cada pedaço.

### Etapa 2 — Guardar conhecimento (fichamento)

Aqui está a diferença em relação a um "chat com PDF" comum. O app não guarda só
pedaços de texto: ele **destila o material em unidades ensináveis**.

Para cada trecho relevante, a LLM extrai:

- **Conceitos** — "ponto de vista em terceira pessoa limitada", "discurso
  indireto livre", "estrutura em três atos". Com definição curta, explicação
  longa, nível de dificuldade e etiquetas temáticas.
- **Exemplos** — trechos literários que ilustram um conceito, com o comentário
  que explica *por que* ilustram.
- **Exercícios** — enunciados de prática, com objetivo pedagógico e tempo
  estimado.

Tudo com **procedência**: cada item aponta para a fonte, o capítulo e a página
de onde saiu. Você sempre consegue voltar ao original.

O resultado é um **acervo didático consultável**, não uma pilha de PDFs.

### Etapa 3 — Preparar o curso

Você informa a demanda:

| Parâmetro | Exemplos |
|---|---|
| Número de encontros | 4, 8, 12, 16 |
| Duração de cada encontro | 90 min, 2 h, 3 h |
| Público | iniciantes, avançados, adolescentes, escritores com originais em andamento |
| Foco | conto, romance, poesia, autoficção, roteiro |
| Modalidade | presencial, online ao vivo, gravado |
| Equilíbrio | mais prática ou mais teoria |
| Carga de leitura | leve, média, pesada |

O app então:

1. Monta uma **ementa** — a espinha dorsal do curso, encontro a encontro, com
   objetivos e conceitos alocados.
2. Mostra a ementa **para você aprovar ou editar** antes de escrever qualquer
   aula. (Detalhe importante: gerar 12 aulas em cima de uma ementa ruim é
   desperdício de tempo e de dinheiro.)
3. Expande cada encontro num **roteiro de aula** completo — abertura, exposição
   dos conceitos, exemplos comentados, exercício, leitura para casa, notas do
   professor.
4. Exporta tudo em **Markdown**, um arquivo por aula.

---

## 3. Decisões técnicas

| Decisão | Escolha | Por quê |
|---|---|---|
| Linguagem | Python 3.12 | Todo o ecossistema de extração de texto, transcrição e busca semântica é nativo aqui. |
| Interface | App web local (FastAPI + Jinja2 + HTMX) | Roda em `localhost`, abre no navegador. Sem etapa de build, sem Node, sem framework de front. Confortável para ler e editar texto longo. |
| Banco | SQLite (arquivo único) | O acervo inteiro num arquivo que você copia, versiona e faz backup. Sem servidor de banco. |
| Busca textual | FTS5 (embutido no SQLite) | Busca por palavra-chave, zero dependência extra. |
| Busca semântica | Embeddings locais + `numpy` | Ver seção 3.1. |
| LLM | DeepSeek V4 via API | Ver seção 3.2. |
| Saída | Markdown | Editável, versionável no git, converte para qualquer coisa depois. |
| Ambiente | `uv` | Rápido e reprodutível. |

### 3.1 Embeddings: locais, não da DeepSeek

Recomendo gerar os embeddings **na sua máquina**, com
`sentence-transformers` rodando um modelo multilíngue forte em português
(`BAAI/bge-m3` ou `intfloat/multilingual-e5-large`).

Três razões:

1. **A DeepSeek não documenta um endpoint de embeddings.** A documentação
   oficial só descreve modelos de chat, e as fontes que afirmam existir um
   `deepseek-embedding-v2` são sites de terceiros que se contradizem — enquanto
   há issues abertas nos repositórios oficiais pedindo justamente esse recurso.
   Não vou apoiar a arquitetura numa coisa que não consegui confirmar na fonte
   primária. **Item a verificar antes da Fase 2**, direto no painel da sua conta.
2. **Custo zero e sem limite de uso.** Você vai reindexar o acervo várias vezes
   enquanto ajusta o tamanho dos trechos. Fazer isso contra uma API paga
   desestimula a experimentação.
3. **Privacidade.** O acervo inteiro fica na sua máquina; só o que a LLM
   precisa ler em cada pedido é enviado para fora.

O código isola isso atrás de uma interface `Embedder`, então trocar por uma API
depois é mudar uma linha de configuração.

**Sobre o índice vetorial**: para um acervo pessoal (estimo algo entre 20 mil e
100 mil trechos), força bruta com `numpy` responde em milissegundos. Não vale a
complexidade de um banco vetorial dedicado. Se um dia passar disso, `sqlite-vec`
entra sem mudar o modelo de dados.

### 3.2 DeepSeek V4 — os dois modelos

A família V4 está em disponibilidade geral desde julho de 2026, com **1M de
tokens de contexto** e API compatível com o formato da OpenAI (o cliente `openai`
do Python funciona apontando para a URL da DeepSeek).

| Modelo | Uso no app | Entrada (1M tokens) | Saída (1M tokens) |
|---|---|---|---|
| `deepseek-v4-flash` | Fichamento em massa: varrer o acervo extraindo conceitos, exemplos e exercícios | US$ 0,14 | US$ 0,28 |
| `deepseek-v4-pro` | Desenho da ementa e escrita dos roteiros de aula | US$ 0,435 | US$ 0,87 |

A divisão importa: o fichamento processa **muito** texto e pede pouco juízo
crítico — é trabalho do Flash. O desenho pedagógico processa **pouco** texto e
pede muito juízo — é trabalho do Pro.

**Ordem de grandeza do custo**: um livro de 300 páginas tem cerca de 150 mil
tokens. Fichá-lo inteiro com o Flash custa por volta de **US$ 0,02**. Gerar um
curso de 12 aulas com o Pro fica na casa de **poucos centavos de dólar**. Na
prática, o custo é irrelevante — o que não quer dizer que o app deva ser
descuidado: ele mostra o consumo por operação.

Dois recursos da V4 que o desenho aproveita de propósito:

- **Contexto de 1M** — capítulos inteiros cabem numa chamada só, sem picotar o
  texto e perder o fio da argumentação do autor.
- **Cache de contexto ligado por padrão** — ao gerar as 12 aulas de um curso, a
  ementa e as instruções se repetem em todos os pedidos. A parte repetida cai
  para uma fração do preço (US$ 0,003625/1M no Pro). Basta manter o prefixo dos
  prompts **estável e no começo** da mensagem. O plano já prevê isso.

### 3.3 Como o app evita inventar coisa

Uma LLM solta escreve uma aula plausível sobre qualquer assunto — e é justamente
o que você *não* quer, porque o valor do app está em usar o **seu** acervo.

Três travas:

1. **Geração ancorada.** O roteiro de aula é escrito a partir dos conceitos,
   exemplos e exercícios recuperados do banco, entregues explicitamente no
   prompt. Não é "escreva uma aula sobre diálogo" — é "escreva uma aula usando
   estes 6 conceitos e estes 4 exemplos".
2. **Citação obrigatória.** Cada conceito e cada exemplo carrega o `id` da fonte
   até o texto final. A aula exportada tem um rodapé de procedência, e você
   consegue conferir a origem de qualquer afirmação.
3. **Aviso de lacuna.** Se a ementa pede um tema que o acervo não cobre bem, o
   app **diz isso** em vez de preencher com conhecimento genérico da LLM — e
   sugere que você ingira material sobre o assunto.

---

## 4. Modelo de dados

```
fonte                 arquivo ingerido
  id, titulo, autor, tipo (livro | artigo | anotacao | obra_literaria |
  transcricao), caminho, hash_sha256, idioma, ano, licenca_uso, ingerido_em

secao                 estrutura interna do documento
  id, fonte_id, titulo, nivel, ordem, pagina_inicio, pagina_fim, texto

trecho                unidade de busca
  id, secao_id, texto, tokens, embedding (BLOB), ordem
  + índice FTS5 sobre `texto`

conceito              unidade ensinável
  id, nome, definicao_curta, explicacao, nivel (iniciante | intermediario |
  avancado), etiquetas[], pre_requisitos[] (outros conceitos)

exemplo               trecho literário que ilustra um conceito
  id, conceito_id, texto, comentario, obra, autor

exercicio             prática
  id, conceito_id, enunciado, objetivo, tempo_estimado_min, modalidade

evidencia             procedência (liga conhecimento à origem)
  id, tipo_alvo (conceito | exemplo | exercicio), alvo_id, trecho_id

curso
  id, titulo, publico, foco, num_encontros, duracao_encontro_min, modalidade,
  equilibrio_pratica_teoria, carga_leitura, objetivos, status, criado_em

aula
  id, curso_id, ordem, titulo, objetivos, conceitos[] , roteiro_markdown,
  leituras, exercicios[], notas_professor, aprovada
```

A tabela `evidencia` é o que sustenta a citação obrigatória da seção 3.3.
A lista `pre_requisitos` em `conceito` é o que permite ordenar o curso por
dificuldade crescente (seção 5).

---

## 5. O algoritmo da ementa

O ponto pedagogicamente delicado. Distribuir conceitos em N encontros não é
sortear — três restrições operam juntas:

1. **Progressão.** Um conceito só entra depois dos seus pré-requisitos. O grafo
   de `pre_requisitos` é ordenado topologicamente; se houver ciclo, o app avisa
   em vez de resolver sozinho.
2. **Carga equilibrada.** Cada encontro recebe um orçamento de tempo
   (`duracao_encontro_min`). Conceitos e exercícios têm custo estimado; a soma
   por encontro respeita o orçamento com folga para conversa e leitura em voz
   alta — na prática, oficina de escrita não cumpre cronograma apertado.
3. **Ritmo.** Alternância entre exposição e prática, seguindo o parâmetro
   `equilibrio_pratica_teoria`. Nenhum encontro fica 100% teórico.

A distribuição inicial é feita por **código** (determinística, auditável,
barata), e só então a LLM entra para **nomear os encontros, escrever os
objetivos e ajustar a narrativa do curso**. Deixar a alocação inteira nas mãos
da LLM produz ementas que parecem boas e estouram o tempo do encontro.

Você vê a ementa numa grade — encontros nas linhas, conceitos nas colunas — e
pode arrastar, remover e travar itens antes de aprovar.

---

## 6. Estrutura do repositório

Raiz do repositório `escritacriativa`; o pacote Python chama-se `escrita`.

```
escritacriativa/
  PLANO.md                    este documento
  README.md                   instruções de instalação e uso
  pyproject.toml              dependências (uv)
  .env.example                DEEPSEEK_API_KEY=...
  escrita/
    __init__.py
    config.py                 configuração e leitura da chave de API
    db.py                     conexão SQLite, migrações, FTS5
    modelos.py                dataclasses/Pydantic espelhando a seção 4
    ingestao/
      __init__.py
      pdf.py                  extração via pymupdf
      epub.py                 ebooklib + BeautifulSoup
      texto.py                .docx, .md, .txt
      audio.py                faster-whisper (transcrição local)
      segmentador.py          texto -> secao -> trecho
    busca/
      embedder.py             interface + implementação local
      indice.py               busca híbrida (FTS5 + vetorial)
    conhecimento/
      extrator.py             trechos -> conceitos/exemplos/exercicios (Flash)
      acervo.py               consultas ao conhecimento destilado
    curso/
      ementa.py               algoritmo da seção 5
      aula.py                 expansão de encontro -> roteiro (Pro)
      exportador.py           -> Markdown
    llm/
      cliente.py              DeepSeek (API compatível com OpenAI)
      prompts/                prompts em arquivos, versionados
    web/
      app.py                  rotas FastAPI
      templates/              Jinja2 + HTMX
      static/
  dados/                      NO .gitignore
    acervo.db                 banco SQLite
    fontes/                   arquivos originais
    cursos/                   Markdown exportado
  tests/
```

**O que não vai para o GitHub**: a pasta `dados/` inteira e o `.env`. Livros,
obras literárias e a chave de API ficam só na sua máquina. O repositório carrega
o código, os prompts e os testes.

---

## 7. Fases de implementação

Cada fase termina com algo que **funciona e você consegue usar**, mesmo que o
resto ainda não exista.

### Fase 0 — Esqueleto
Projeto, dependências, banco vazio com as migrações, configuração da chave de
API, app web subindo em `localhost` com uma página vazia.
*Entrega: `uv run escrita` abre o navegador.*

### Fase 1 — Ingestão
Upload de arquivo pela interface, extração de PDF/EPUB/DOCX/MD/TXT, segmentação
em seções e trechos, listagem do acervo com contagem de páginas e trechos.
*Entrega: você joga um livro dentro e vê o texto extraído, organizado por capítulo.*

### Fase 2 — Busca
Embeddings locais, índice FTS5, busca híbrida com tela de resultados mostrando
trecho + fonte + página.
*Entrega: "onde meus livros falam sobre ponto de vista?" devolve trechos reais com procedência.*

### Fase 3 — Fichamento
Extração de conceitos, exemplos e exercícios via `deepseek-v4-flash`, com saída
estruturada validada por Pydantic. Tela de revisão para você aprovar, editar ou
descartar cada item extraído — o acervo é seu, a LLM só faz o primeiro rascunho.
*Entrega: acervo didático navegável por conceito.*

### Fase 4 — Ementa
Formulário de demanda, algoritmo de distribuição, grade editável, aprovação.
*Entrega: ementa de um curso de 8 encontros, revisada por você.*

### Fase 5 — Aulas e exportação
Expansão de cada encontro em roteiro via `deepseek-v4-pro`, edição no app,
exportação para Markdown com rodapé de procedência.
*Entrega: o curso completo em arquivos `.md`.*

### Fase 6 — Refinamentos
Transcrição de áudio/vídeo com `faster-whisper`; chat livre com o acervo;
duplicar e adaptar um curso existente para outro público; detecção de conceitos
duplicados vindos de fontes diferentes.

**Sugestão de ordem de trabalho**: Fases 0–2 entregam valor sozinhas (uma busca
semântica decente no seu acervo já muda seu preparo de aula). Vale rodar assim
por alguns dias e ajustar o tamanho dos trechos antes de investir na Fase 3.

---

## 8. Pontos de atenção

**Direito autoral.** O acervo vai conter obras protegidas. Enquanto o uso for
pessoal e o material distribuído aos alunos citar fonte e se limitar a trechos
curtos, o terreno é o de sempre no ensino. O que **não** deve acontecer é o app
exportar capítulos inteiros de terceiros dentro de uma apostila. O campo
`licenca_uso` em `fonte` existe para você marcar o que é livre, o que é seu e o
que é de terceiros — e o exportador respeita isso, limitando o tamanho das
citações de material protegido.

**Privacidade.** Fichamento e geração enviam trechos do seu acervo para os
servidores da DeepSeek. Não há como usar LLM na nuvem sem isso. Se algum
material for sensível (originais inéditos de alunos, por exemplo), marque a
fonte como local e o app a mantém fora das chamadas de API. Se um dia quiser
tudo offline, a interface `ClienteLLM` aceita um modelo local via Ollama — mais
lento e mais fraco, mas o desenho não impede.

**Qualidade do PDF.** PDF escaneado sem camada de texto não extrai nada. A Fase
1 detecta isso e avisa; OCR fica para a Fase 6, se aparecer necessidade real.

**A verificar antes da Fase 2.** Se a sua conta DeepSeek expõe um endpoint de
embeddings — a documentação pública não confirma (seção 3.1). Não bloqueia nada:
o plano já assume embeddings locais.

---

## 9. Próximo passo

Este documento fecha o **planejamento**. O repositório de destino já existe —
falta liberar o acesso desta sessão a ele (veja o *Status* no topo). Feito isso:

1. Movo o conteúdo desta pasta para a raiz de `rniepce/escritacriativa` e
   removo a pasta daqui, deixando o `moneymanager` de volta como estava.
2. Implemento a Fase 0 e a Fase 1, para você já conseguir ingerir seu primeiro
   livro.

Se quiser mudar alguma coisa do desenho, o melhor momento é agora — a seção 4
(modelo de dados) e a seção 5 (algoritmo da ementa) são as que mais custam para
alterar depois.
