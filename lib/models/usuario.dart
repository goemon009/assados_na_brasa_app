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
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      login: map['login'],
      senha: map['senha'],
      tipoUsuario: map['tipo_usuario'],
      status: map['status'],
    );
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
