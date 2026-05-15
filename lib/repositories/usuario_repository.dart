import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/usuario.dart';

class UsuarioRepositoryException implements Exception {
  const UsuarioRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UsuarioRepository {
  UsuarioRepository({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient? _supabaseClient;

  SupabaseClient get _supabase => _supabaseClient ?? Supabase.instance.client;

  String _traduzirErroUsuario(
    PostgrestException exception, {
    required String operacao,
  }) {
    final String message = exception.message.toLowerCase();

    if (message.contains('row-level security policy') &&
        message.contains('"usuarios"')) {
      return 'O Supabase bloqueou a operação "$operacao" na tabela usuarios. Execute o script sql/supabase_usuarios.sql para liberar o CRUD direto.';
    }

    return 'Erro ao $operacao usuário: ${exception.message}';
  }

  Future<Usuario?> login(String login, String senha) async {
    final String loginNormalizado = login.trim();
    final String senhaNormalizada = senha.trim();

    if (loginNormalizado.isEmpty || senhaNormalizada.isEmpty) {
      return null;
    }

    try {
      final List<dynamic> response = await _supabase
          .rpc(
            'login_usuario',
            params: {
              'p_login': loginNormalizado,
              'p_senha': senhaNormalizada,
            },
          )
          .select();

      final usuarios = response
          .map((item) => Usuario.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      for (final usuario in usuarios) {
        if (usuario.ativo) {
          return usuario;
        }
      }

      return null;
    } on PostgrestException catch (e) {
      final String message = e.message.toLowerCase();

      if (message.contains('login_usuario')) {
        throw const UsuarioRepositoryException(
          'A função login_usuario ainda não existe no Supabase. Crie a função SQL no banco para liberar o login.',
        );
      }

      throw UsuarioRepositoryException(
        'Não foi possível executar o login no Supabase: ${e.message}',
      );
    }
  }

  Future<List<Usuario>> listarUsuarios() async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select('id, nome, login, senha, tipo_usuario, status')
          .order('nome');

      final usuarios = (response as List)
          .map((item) => Usuario.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      usuarios.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );

      return usuarios;
    } on PostgrestException catch (e) {
      throw UsuarioRepositoryException(
        'Erro ao listar usuários: ${e.message}',
      );
    }
  }

  Future<void> cadastrarUsuario(Usuario usuario) async {
    try {
      await _supabase.from('usuarios').insert(usuario.toMap());
    } on PostgrestException catch (e) {
      throw UsuarioRepositoryException(
        _traduzirErroUsuario(e, operacao: 'cadastrar'),
      );
    }
  }

  Future<void> atualizarUsuario(Usuario usuario) async {
    if (usuario.id == null) {
      throw const UsuarioRepositoryException(
        'Não é possível atualizar um usuário sem ID.',
      );
    }

    try {
      await _supabase
          .from('usuarios')
          .update(usuario.toMap())
          .eq('id', usuario.id!);
    } on PostgrestException catch (e) {
      throw UsuarioRepositoryException(
        _traduzirErroUsuario(e, operacao: 'atualizar'),
      );
    }
  }

  Future<void> excluirUsuario(int id) async {
    try {
      await _supabase.from('usuarios').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw UsuarioRepositoryException(
        _traduzirErroUsuario(e, operacao: 'excluir'),
      );
    }
  }
}
