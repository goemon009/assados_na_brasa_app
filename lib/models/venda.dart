class Venda {
  final int? id;
  final DateTime dataVenda;
  final double valorTotal;
  final String formaPagamento;
  final int idCliente;
  final int idUsuario;

  Venda({
    this.id,
    required this.dataVenda,
    required this.valorTotal,
    required this.formaPagamento,
    required this.idCliente,
    required this.idUsuario,
  });

  factory Venda.fromMap(Map<String, dynamic> map) {
    return Venda(
      id: map['id'],
      dataVenda: DateTime.parse(map['data_venda']),
      valorTotal: (map['valor_total'] as num).toDouble(),
      formaPagamento: map['forma_pagamento'],
      idCliente: map['id_cliente'],
      idUsuario: map['id_usuario'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data_venda': dataVenda.toIso8601String(),
      'valor_total': valorTotal,
      'forma_pagamento': formaPagamento,
      'id_cliente': idCliente,
      'id_usuario': idUsuario,
    };
  }
}
