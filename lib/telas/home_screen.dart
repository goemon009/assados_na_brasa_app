import 'package:flutter/material.dart';

import '../models/usuario.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.usuario});

  final Usuario? usuario;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _saindo = false;

  Future<void> _sair() async {
    setState(() {
      _saindo = true;
    });

    try {
      if (!mounted) return;

      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saindo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Usuario? usuario = widget.usuario;
    final String nomeExibicao = usuario?.nome.trim().isNotEmpty == true
        ? usuario!.nome.trim()
        : 'Usuário';
    final String loginExibicao = usuario?.login.trim().isNotEmpty == true
        ? usuario!.login.trim()
        : 'Sem identificação';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assados na Brasa'),
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _saindo ? null : _sair,
            icon: _saindo
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout, color: Colors.white),
            label: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo, $nomeExibicao',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text('Acesso: $loginExibicao'),
                    const SizedBox(height: 8),
                    Text('Origem da autenticação: tabela usuarios'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
