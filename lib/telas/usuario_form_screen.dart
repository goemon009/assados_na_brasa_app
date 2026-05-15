import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class UsuarioFormScreen extends StatefulWidget {
  const UsuarioFormScreen({
    super.key,
    this.usuario,
  });

  final Usuario? usuario;

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final UsuarioRepository _repository = UsuarioRepository();

  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();

  String _tipoUsuario = 'O';
  String _status = 'ATIVO';

  bool _salvando = false;

  bool get _editando => widget.usuario != null;

  @override
  void initState() {
    super.initState();

    if (_editando) {
      final usuario = widget.usuario!;

      _nomeController.text = usuario.nome;
      _loginController.text = usuario.login;
      _senhaController.text = usuario.senha;
      _tipoUsuario = usuario.tipoUsuario;
      _status = usuario.status;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
    });

    try {
      final usuario = Usuario(
        id: widget.usuario?.id,
        nome: _nomeController.text.trim(),
        login: _loginController.text.trim(),
        senha: _senhaController.text.trim(),
        tipoUsuario: _tipoUsuario,
        status: _status,
      );

      if (_editando) {
        await _repository.atualizarUsuario(usuario);
      } else {
        await _repository.cadastrarUsuario(usuario);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Usuário atualizado com sucesso.'
                : 'Usuário cadastrado com sucesso.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } on UsuarioRepositoryException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar usuário: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _loginController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: AppBar(
        title: Text(_editando ? 'Editar Usuário' : 'Novo Usuário'),
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 4,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _loginController,
                        decoration: const InputDecoration(
                          labelText: 'Login',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o login.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a senha.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _tipoUsuario,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de usuário',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.admin_panel_settings),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'O',
                            child: Text('Operador'),
                          ),
                          DropdownMenuItem(
                            value: 'A',
                            child: Text('Administrador'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _tipoUsuario = value ?? 'O';
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.toggle_on),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'ATIVO',
                            child: Text('ATIVO'),
                          ),
                          DropdownMenuItem(
                            value: 'INATIVO',
                            child: Text('INATIVO'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _status = value ?? 'ATIVO';
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _salvando ? null : _salvar,
                          icon: _salvando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _salvando
                                ? 'Salvando...'
                                : _editando
                                    ? 'Salvar Alterações'
                                    : 'Cadastrar Usuário',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8FA55A),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
