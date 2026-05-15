import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';
import 'cliente_screen.dart';
import 'produtos_screen.dart';
import 'usuarios_screen.dart';
import 'vendas_screen.dart';

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
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: AppLogo(width: 150),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Bem-vindo, $nomeExibicao',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // BOTÃO USUÁRIOS (somente admin)
                    if (usuario?.administrador == true) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UsuariosScreen(
                                  usuarioLogado: usuario!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Usuários'),
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
                    ],

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProdutosScreen(),
                            ),
                          );
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
                          if (usuario == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Usuário logado não encontrado.',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VendasScreen(usuario: usuario),
                            ),
                          );
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
                          side: const BorderSide(
                            color: Color(0xFF8FA55A),
                          ),
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