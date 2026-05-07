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
            params: {'p_login': loginNormalizado, 'p_senha': senhaNormalizada},
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
}
