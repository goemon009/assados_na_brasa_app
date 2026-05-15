import 'package:flutter/material.dart';

import '../models/usuario.dart';
import 'login_screen.dart';
import 'cliente_screen.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: AppBar(
        title: const Text('Assados na Brasa'),
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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

                    const SizedBox(height: 32),

                    // BOTÃO CLIENTES
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ClientesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people),
                        label: const Text('Clientes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8FA55A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BOTÃO PRODUTOS
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // futura tela de produtos
                        },
                        icon: const Icon(Icons.inventory_2),
                        label: const Text('Produtos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8FA55A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BOTÃO VENDAS
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // futura tela de vendas
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Vendas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8FA55A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _saindo ? null : _sair,
                        icon: _saindo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout),
                        label: Text(_saindo ? 'Saindo...' : 'Sair'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8FA55A),
                          side: const BorderSide(color: Color(0xFF8FA55A)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }
}
