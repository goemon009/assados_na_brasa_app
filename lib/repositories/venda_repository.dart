import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/venda.dart';
import '../models/item_venda.dart';
import '../models/produto.dart';

class VendaRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> registrarVenda({
    required Venda venda,
    required List<ItemVenda> itens,
    required List<Produto> produtos,
  }) async {
    if (itens.isEmpty) {
      throw Exception('A venda precisa ter pelo menos um item.');
    }

    final vendaInserida = await _supabase
        .from('vendas')
        .insert(venda.toMap())
        .select('id')
        .single();

    final int idVenda = vendaInserida['id'];

    for (final item in itens) {
      final itemComVenda = ItemVenda(
        idVenda: idVenda,
        idProduto: item.idProduto,
        quantidade: item.quantidade,
        subtotal: item.subtotal,
      );

      await _supabase.from('itens_venda').insert(itemComVenda.toMap());

      final Produto produto = produtos.firstWhere(
        (p) => p.id == item.idProduto,
      );

      final int novoEstoque = produto.estoque - item.quantidade;

      if (novoEstoque < 0) {
        throw Exception(
          'Estoque insuficiente para o produto ${produto.nomeProduto}.',
        );
      }

      await _supabase
          .from('produtos')
          .update({'estoque': novoEstoque})
          .eq('id', produto.id!);
    }

    return idVenda;
  }

  Future<List<Venda>> listarVendasPorData(DateTime data) async {
    final inicioDoDia = DateTime(data.year, data.month, data.day);
    final proximoDia = inicioDoDia.add(const Duration(days: 1));

    final response = await _supabase
        .from('vendas')
        .select()
        .gte('data_venda', inicioDoDia.toIso8601String())
        .lt('data_venda', proximoDia.toIso8601String())
        .order('data_venda', ascending: false);

    return (response as List)
        .map((venda) => Venda.fromMap(venda))
        .toList();
  }

  double calcularTotalVendas(List<Venda> vendas) {
    return vendas.fold(
      0,
      (total, venda) => total + venda.valorTotal,
    );
  }
}