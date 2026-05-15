import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';
import 'cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteRepository _repository = ClienteRepository();

  List<Cliente> _clientes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() {
      _carregando = true;
    });

    try {
      final clientes = await _repository.listarClientes();

      setState(() {
        _clientes = clientes;
      });
    } catch (e) {
      _mostrarMensagem('Erro ao carregar clientes: $e');
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _confirmarExclusao(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text('Deseja realmente excluir o cliente "${cliente.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await _repository.excluirCliente(cliente.id!);
        _mostrarMensagem('Cliente excluído com sucesso.');
        _carregarClientes();
      } catch (e) {
        _mostrarMensagem('Erro ao excluir cliente: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ClienteFormScreen(),
            ),
          );

          if (resultado == true) {
            _carregarClientes();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _clientes.isEmpty
              ? const Center(
                  child: Text('Nenhum cliente cadastrado.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = _clientes[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(cliente.nome),
                        subtitle: Text(
                          'CPF: ${cliente.cpf ?? "-"}\n'
                          'Telefone: ${cliente.telefone ?? "-"}\n'
                          'Status: ${cliente.status}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'editar') {
                              final resultado = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClienteFormScreen(cliente: cliente),
                                ),
                              );

                              if (resultado == true) {
                                _carregarClientes();
                              }
                            } else if (value == 'excluir') {
                              _confirmarExclusao(cliente);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
