import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';    

class UsuarioRepository {
    final SupabaseCliente _supabase = Supabase.instance.client;

    Future<usuario?> login(String login, String senha) async {
        final response = await _supabase
        .from('usuario')
        .select()
        .eq('login', login)
        .eq('senha', senha)
        .eq('status', 'ATIVO')
        .maybeSingle();
    }

    if(response == null) {
        return null;
    }

    return usuario.fromMap(response);
}