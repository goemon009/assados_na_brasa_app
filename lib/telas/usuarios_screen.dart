import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';
import 'usuario_form_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({
    super.key,
    required this.usuarioLogado,
  });

  final Usuario usuarioLogado;

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UsuarioRepository _repository = UsuarioRepository();

  List<Usuario> _usuarios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();

    if (!widget.usuarioLogado.administrador) {
      Future.microtask(() {
        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Apenas administradores podem acessar esta tela.',
            ),
          ),
        );
      });

      return;
    }

    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _carregando = true;
    });

    try {
      final usuarios = await _repository.listarUsuarios();

      setState(() {
        _usuarios = usuarios;
      });
    } catch (e) {
      _mostrarMensagem('Erro ao carregar usuários: $e');
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _abrirCadastroUsuario() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UsuarioFormScreen(),
      ),
    );

    if (resultado == true) {
      _carregarUsuarios();
    }
  }

  Future<void> _abrirEdicaoUsuario(Usuario usuario) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UsuarioFormScreen(usuario: usuario),
      ),
    );

    if (resultado == true) {
      _carregarUsuarios();
    }
  }

  Future<void> _confirmarExclusao(Usuario usuario) async {
    if (usuario.id == widget.usuarioLogado.id) {
      _mostrarMensagem('Você não pode excluir o próprio usuário logado.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Deseja realmente excluir o usuário "${usuario.nome}"?',
          ),
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
        await _repository.excluirUsuario(usuario.id!);
        _mostrarMensagem('Usuário excluído com sucesso.');
        _carregarUsuarios();
      } catch (e) {
        _mostrarMensagem('Erro ao excluir usuário: $e');
      }
    }
  }

  String _descricaoTipoUsuario(String tipo) {
    final tipoNormalizado = tipo.trim().toUpperCase();

    if (tipoNormalizado == 'A') {
      return 'Administrador';
    }

    if (tipoNormalizado == 'O') {
      return 'Operador';
    }

    return tipo;
  }

  Color _corTipoUsuario(String tipo) {
    final tipoNormalizado = tipo.trim().toUpperCase();

    if (tipoNormalizado == 'A') {
      return Colors.red;
    }

    return Colors.blue;
  }

  Color _corStatus(String status) {
    final statusNormalizado = status.trim().toUpperCase();

    if (statusNormalizado == 'ATIVO') {
      return Colors.green;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: AppBar(
        title: const Text('Usuários'),
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
        onPressed: _abrirCadastroUsuario,
        child: const Icon(Icons.add),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? const Center(
                  child: Text('Nenhum usuário cadastrado.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = _usuarios[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _corTipoUsuario(usuario.tipoUsuario),
                          foregroundColor: Colors.white,
                          child: Text(
                            usuario.tipoUsuario.toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(usuario.nome),
                        subtitle: Text(
                          'Login: ${usuario.login}\n'
                          'Tipo: ${_descricaoTipoUsuario(usuario.tipoUsuario)}\n'
                          'Status: ${usuario.status}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              _abrirEdicaoUsuario(usuario);
                            } else if (value == 'excluir') {
                              _confirmarExclusao(usuario);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem(
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
