class Usuario {
  final int? id;
  final String nome;
  final String login;
  final String senha;
  final String tipoUsuario;
  final String status;

  Usuario({
    this.id,
    required this.nome,
    required this.login,
    required this.senha,
    required this.tipoUsuario,
    required this.status,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    String readString(String key) => map[key]?.toString() ?? '';

    return Usuario(
      id: (map['id'] as num?)?.toInt(),
      nome: readString('nome'),
      login: readString('login'),
      senha: readString('senha'),
      tipoUsuario: readString('tipo_usuario'),
      status: readString('status'),
    );
  }

  bool get ativo {
    final normalized = status.trim().toUpperCase();
    return normalized.isEmpty ||
        normalized == 'A' ||
        normalized == 'ATIVO' ||
        normalized == '1' ||
        normalized == 'S';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'login': login,
      'senha': senha,
      'tipo_usuario': tipoUsuario,
      'status': status,
    };
  }
}
