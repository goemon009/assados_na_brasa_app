# Assados na Brasa Mobile

Aplicativo Flutter do estabelecimento Assados na Brasa, integrado ao Supabase para autenticação e operações de cadastro.

## Visão Geral

O projeto foi criado para levar a operação do Assados na Brasa para o mobile, mantendo os fluxos principais da versão web com uma interface simples e direta para uso interno.

No estado atual, o app já entrega:

- login com validação no Supabase via função RPC
- tela inicial com identificação do usuário autenticado
- CRUD completo de clientes
- base visual em Material 3

Os módulos de produtos e vendas já possuem arquivos reservados no projeto, mas ainda não estão ligados à navegação nem implementados na interface.

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
- função RPC `login_usuario`

### Tabela `clientes`

Campos esperados pelo app:

- `id`
- `nome`
- `cpf`
- `telefone`
- `endereco`
- `status`

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
- listagem de clientes
- cadastro de clientes
- edição de clientes
- exclusão de clientes

### Em aberto

- navegação para produtos
- navegação para vendas
- implementação das telas de produtos
- implementação das telas de vendas

## Testes

O projeto possui teste de widget cobrindo a renderização da tela de login:

```bash
flutter test
```

## Observações

- A chave `anonKey` do Supabase está versionada no repositório. Para produção, o ideal é mover essa configuração para uma estratégia mais segura.
- O app mobile não contempla, por enquanto, o controle de inadimplência citado como exceção da versão web.
