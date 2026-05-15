import 'package:assados_na_brasa_mobile/models/produto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdutoRepositoryException implements Exception {
  const ProdutoRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProdutoRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _traduzirErro(PostgrestException exception) {
    final message = exception.message.toLowerCase();

    if (message.contains('null value in column "id"') &&
        message.contains('relation "produtos"')) {
      return 'A coluna id da tabela produtos no Supabase nao esta gerando valor automaticamente. Configure esse campo como auto incremento (identity/serial).';
    }

    return 'Nao foi possivel salvar o produto no Supabase: ${exception.message}';
  }

  Future<List<Produto>> listarProdutos() async {
    final response = await _supabase
        .from('produtos')
        .select()
        .order('nome_produto');

    final produtos = (response as List)
        .map((produtoMap) => Produto.fromMap(Map<String, dynamic>.from(produtoMap)))
        .toList();

    produtos.sort(
      (a, b) => a.nomeProduto.toLowerCase().compareTo(b.nomeProduto.toLowerCase()),
    );

    return produtos;
  }

  Future<void> cadastrarProduto(Produto produto) async {
    try {
      await _supabase.from('produtos').insert(produto.toMap());
    } on PostgrestException catch (e) {
      throw ProdutoRepositoryException(_traduzirErro(e));
    }
  }

  Future<void> atualizarProduto(Produto produto) async {
    if (produto.id == null) {
      throw ArgumentError('Produto sem id nao pode ser atualizado.');
    }

    try {
      await _supabase
          .from('produtos')
          .update(produto.toMap())
          .eq('id', produto.id!);
    } on PostgrestException catch (e) {
      throw ProdutoRepositoryException(_traduzirErro(e));
    }
  }

  Future<void> excluirProduto(int id) async {
    await _supabase.from('produtos').delete().eq('id', id);
  }
}
