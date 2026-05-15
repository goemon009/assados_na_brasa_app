import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cliente.dart';

class ClienteRepository {
    final SupabaseClient _supabase = Supabase.instance.client;

    //Listar Cliente
    Future<List<Cliente>> listarClientes() async {
        final response = await _supabase
            .from('clientes')
            .select()
            .order('nome');

        final clientes = (response as List)
            .map((cliente) => Cliente.fromMap(cliente))
            .toList();

        clientes.sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );

        return clientes;
    }

    //Cadastrar Cliente
    Future<void> cadastrarCliente(Cliente cliente) async {
        await _supabase
            .from('clientes')
            .insert(cliente.toMap());
    }    

    //Atualizar Cliente
    Future<void> atualizarCliente(Cliente cliente) async {
        if (cliente.id == null) {
            throw ArgumentError('Cliente sem id não pode ser atualizado.');
        }

        await _supabase
            .from('clientes')
            .update(cliente.toMap())
            .eq('id', cliente.id!);
    }

    //Excluir Cliente
    Future<void> excluirCliente(int id) async {
        await _supabase
            .from('clientes')
            .delete()
            .eq('id', id);
    }

}
