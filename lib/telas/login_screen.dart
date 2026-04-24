import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _carregando = false;

  Future<void> _entrar() async {
    final login = _loginController.text.trim();
    final senha = _senhaController.text.trim();

    if (login.isEmpty || senha.isEmpty) {
      _mostrarMensagem('Informe login e senha.');
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final Usuario? usuario = await _usuarioRepository.login(login, senha);

      if (!mounted) return;

      if (usuario == null) {
        _mostrarMensagem('Usuário ou senha inválidos.');
        return;
      }

      _mostrarMensagem('Bem-vindo, ${usuario.nome}!');

      // Depois vamos trocar isso pela HomeScreen
      // Navigator.pushReplacement(...)

    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Erro ao realizar login: $e');
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

  @override
  void dispose() {
    _loginController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Assados na Brasa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: _loginController,
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _entrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8FA55A),
                        foregroundColor: Colors.white,
                      ),
                      child: _carregando
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('ACESSAR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}