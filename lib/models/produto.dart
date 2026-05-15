class Produto {
  final int? id;
  final String nomeProduto;
  final double preco;
  final int estoque;

  Produto({
    this.id,
    required this.nomeProduto,
    required this.preco,
    required this.estoque,
  });

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: (map['id'] as num?)?.toInt(),
      nomeProduto: map['nome_produto']?.toString() ?? '',
      preco: (map['preco'] as num).toDouble(),
      estoque: (map['estoque'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'nome_produto': nomeProduto,
      'preco': preco,
      'estoque': estoque,
    };

    if (includeId && id != null) {
      map['id'] = id;
    }

    return map;
  }
}
