class ItemVenda {
  final int? id;
  final int? idVenda;
  final int idProduto;
  final int quantidade;
  final double subtotal;

  ItemVenda({
    this.id,
    this.idVenda,
    required this.idProduto,
    required this.quantidade,
    required this.subtotal,
  });

  factory ItemVenda.fromMap(Map<String, dynamic> map) {
    return ItemVenda(
      id: map['id'],
      idVenda: map['id_venda'],
      idProduto: map['id_produto'],
      quantidade: map['quantidade'],
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_venda': idVenda,
      'id_produto': idProduto,
      'quantidade': quantidade,
      'subtotal': subtotal,
    };
  }
}
