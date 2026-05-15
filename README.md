# Assados na Brasa Mobile

Aplicativo Flutter do estabelecimento Assados na Brasa, integrado ao Supabase para autenticação, cadastros operacionais e registro de vendas.

## Visão Geral

O projeto foi criado para levar a operação do Assados na Brasa para o mobile, mantendo os fluxos principais da versão web com uma interface simples e direta para uso interno.

No estado atual, o app já entrega:

- login com validação no Supabase via função RPC
- tela inicial com logo e identificação do usuário autenticado
- controle de acesso para área de usuários
- CRUD de usuários
- CRUD de clientes
- CRUD de produtos
- fluxo de vendas com histórico diário, filtro por data e abertura de nova venda
- base visual em Material 3

## Stack

- Flutter
- Dart
- Supabase
- Material 3

## Estrutura do Projeto

```text
lib/
  config/         Configuração do Supabase
  models/         Modelos de domínio
  repositories/   Acesso a dados no Supabase
  telas/          Telas da aplicação
  widgets/        Componentes reutilizáveis
assets/           Logo e arquivos visuais
sql/              Scripts auxiliares para o Supabase
test/             Testes de widget
```

## Requisitos

- Flutter SDK compatível com Dart `^3.10.8`
- Android Studio ou toolchain Flutter configurada
- Projeto Supabase com as tabelas e funções esperadas pela aplicação

## Como Executar

```bash
flutter pub get
flutter run
```

## Configuração do Supabase

Atualmente a inicialização do Supabase é feita em [`lib/config/supabase_config.dart`](lib/config/supabase_config.dart) com `url` e `anonKey` fixos no código.

Para o app funcionar corretamente, o backend precisa expor:

- tabela `clientes`
- tabela `produtos`
- tabela `usuarios`
- tabela `vendas`
- tabela `itens_venda`
- função RPC `login_usuario`
- políticas RLS compatíveis com o CRUD da tabela `usuarios`

### Tabela `clientes`

Campos esperados pelo app:

- `id`
- `nome`
- `cpf`
- `telefone`
- `endereco`
- `status`

### Tabela `produtos`

Campos esperados pelo app:

- `id`
- `nome_produto`
- `preco`
- `estoque`

Importante:

- a coluna `id` precisa gerar valor automaticamente no banco

### Tabela `usuarios`

Campos esperados pelo app:

- `id`
- `nome`
- `login`
- `senha`
- `tipo_usuario`
- `status`

Para liberar o CRUD direto de usuários com a `anonKey` atual, execute o script:

- [`sql/supabase_usuarios.sql`](sql/supabase_usuarios.sql)

### Tabelas `vendas` e `itens_venda`

Campos usados pelo app:

- `vendas.id`
- `vendas.data_venda`
- `vendas.valor_total`
- `vendas.forma_pagamento`
- `vendas.id_cliente`
- `vendas.id_usuario`
- `itens_venda.id`
- `itens_venda.id_venda`
- `itens_venda.id_produto`
- `itens_venda.quantidade`
- `itens_venda.subtotal`

### Função `login_usuario`

A função deve receber:

- `p_login`
- `p_senha`

E retornar os campos usados pelo app:

- `id`
- `nome`
- `login`
- `senha`
- `tipo_usuario`
- `status`

Se a função ainda não existir no Supabase, o login falhará com uma mensagem específica orientando a criação dela no banco.

## Funcionalidades Atuais

### Implementadas

- autenticação por login e senha
- tela inicial com logo centralizada
- navegação para usuários, clientes, produtos e vendas
- listagem de usuários
- cadastro de usuários
- edição de usuários
- exclusão de usuários
- listagem de clientes
- cadastro de clientes
- edição de clientes
- exclusão de clientes
- listagem de produtos
- cadastro de produtos
- edição de produtos
- exclusão de produtos
- vendas do dia com filtro por data
- histórico diário de vendas
- abertura de nova venda em tela dedicada
- busca digitada de cliente no fluxo de venda
- controle de estoque ao registrar venda
- ordenação alfabética para clientes, produtos e usuários

### Em aberto

- validação automatizada além do teste básico de login
- revisão de segurança das policies de `usuarios`
- endurecimento da estratégia de credenciais do Supabase

## Testes

O projeto possui teste de widget cobrindo a renderização da tela de login:

```bash
flutter test
```

## Observações

- A chave `anonKey` do Supabase está versionada no repositório. Para produção, o ideal é mover essa configuração para uma estratégia mais segura.
- O CRUD direto de `usuarios` depende das policies do script [`sql/supabase_usuarios.sql`](sql/supabase_usuarios.sql).
- Não consegui validar com `flutter test` neste ambiente porque a instalação local do Flutter está quebrada.
