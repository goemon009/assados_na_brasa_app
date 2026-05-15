import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../repositories/produto_repository.dart';
import 'produto_form_screen.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final ProdutoRepository _repository = ProdutoRepository();

  List<Produto> _produtos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _carregando = true;
    });

    try {
      final produtos = await _repository.listarProdutos();

      setState(() {
        _produtos = produtos;
      });
    } catch (e) {
      _mostrarMensagem('Erro ao carregar produtos: $e');
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

  Future<void> _abrirCadastroProduto() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProdutoFormScreen(),
      ),
    );

    if (resultado == true) {
      _carregarProdutos();
    }
  }

  Future<void> _abrirEdicaoProduto(Produto produto) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProdutoFormScreen(produto: produto),
      ),
    );

    if (resultado == true) {
      _carregarProdutos();
    }
  }

  Future<void> _confirmarExclusao(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Deseja realmente excluir o produto "${produto.nomeProduto}"?',
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
        await _repository.excluirProduto(produto.id!);
        _mostrarMensagem('Produto excluído com sucesso.');
        _carregarProdutos();
      } catch (e) {
        _mostrarMensagem('Erro ao excluir produto: $e');
      }
    }
  }

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Color _corEstoque(int estoque) {
    if (estoque <= 5) {
      return Colors.red;
    } else if (estoque <= 20) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
        onPressed: _abrirCadastroProduto,
        child: const Icon(Icons.add),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _produtos.isEmpty
              ? const Center(
                  child: Text('Nenhum produto cadastrado.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _produtos.length,
                  itemBuilder: (context, index) {
                    final produto = _produtos[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(produto.nomeProduto),
                        subtitle: Text(
                          'Preço: ${_formatarPreco(produto.preco)}\n'
                          'Estoque: ${produto.estoque} un.',
                        ),
                        isThreeLine: true,
                        leading: CircleAvatar(
                          backgroundColor: _corEstoque(produto.estoque),
                          foregroundColor: Colors.white,
                          child: Text(
                            produto.estoque.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              _abrirEdicaoProduto(produto);
                            } else if (value == 'excluir') {
                              _confirmarExclusao(produto);
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
