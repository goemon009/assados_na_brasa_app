import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../models/item_venda.dart';
import '../models/produto.dart';
import '../models/usuario.dart';
import '../models/venda.dart';
import '../repositories/cliente_repository.dart';
import '../repositories/produto_repository.dart';
import '../repositories/venda_repository.dart';

class VendasScreen extends StatefulWidget {
  const VendasScreen({
    super.key,
    required this.usuario,
  });

  final Usuario usuario;

  @override
  State<VendasScreen> createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> {
  final ClienteRepository _clienteRepository = ClienteRepository();
  final ProdutoRepository _produtoRepository = ProdutoRepository();
  final VendaRepository _vendaRepository = VendaRepository();

  List<Venda> _vendasDoDia = [];
  DateTime _dataFiltro = DateTime.now();

  bool _carregando = true;
  bool _abrindoNovaVenda = false;

  @override
  void initState() {
    super.initState();
    _carregarVendasDoDia();
  }

  Future<void> _carregarVendasDoDia() async {
    setState(() {
      _carregando = true;
    });

    try {
      final vendas = await _vendaRepository.listarVendasPorData(_dataFiltro);

      if (!mounted) return;

      setState(() {
        _vendasDoDia = vendas;
      });
    } catch (e) {
      _mostrarMensagem('Erro ao carregar vendas: $e');
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _iniciarVenda() async {
    setState(() {
      _abrindoNovaVenda = true;
    });

    try {
      final results = await Future.wait<dynamic>([
        _clienteRepository.listarClientes(),
        _produtoRepository.listarProdutos(),
      ]);

      final clientes = results[0] as List<Cliente>;
      final produtos = results[1] as List<Produto>;

      if (!mounted) return;

      if (clientes.isEmpty) {
        _mostrarMensagem(
          'Cadastre pelo menos um cliente antes de iniciar uma venda.',
        );
        return;
      }

      if (produtos.isEmpty) {
        _mostrarMensagem(
          'Cadastre pelo menos um produto antes de iniciar uma venda.',
        );
        return;
      }

      final resultado = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (_) => _NovaVendaScreen(
            usuario: widget.usuario,
            clientes: clientes,
            produtos: produtos,
            vendaRepository: _vendaRepository,
          ),
        ),
      );

      if (resultado == true) {
        _mostrarMensagem('Venda registrada com sucesso.');
        await _carregarVendasDoDia();
      }
    } catch (e) {
      _mostrarMensagem('Erro ao preparar nova venda: $e');
    } finally {
      if (mounted) {
        setState(() {
          _abrindoNovaVenda = false;
        });
      }
    }
  }

  Future<void> _selecionarDataFiltro() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataFiltro,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataFiltro = dataSelecionada;
      });

      await _carregarVendasDoDia();
    }
  }

  double get _totalVendidoNaData {
    return _vendaRepository.calcularTotalVendas(_vendasDoDia);
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  String _formatarHora(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: AppBar(
        title: const Text('Vendas'),
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildResumoDoDia(),
                  const SizedBox(height: 16),
                  _buildAcaoIniciarVenda(),
                  const SizedBox(height: 16),
                  _buildVendasDoDia(),
                ],
              ),
            ),
    );
  }

  Widget _buildResumoDoDia() {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: ListTile(
        title: Text('Vendas de ${_formatarData(_dataFiltro)}'),
        subtitle: Text('Total vendido: ${_formatarMoeda(_totalVendidoNaData)}'),
        trailing: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: _selecionarDataFiltro,
        ),
      ),
    );
  }

  Widget _buildAcaoIniciarVenda() {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _abrindoNovaVenda ? null : _iniciarVenda,
            icon: _abrindoNovaVenda
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.point_of_sale),
            label: Text(_abrindoNovaVenda ? 'Abrindo...' : 'Iniciar Venda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8FA55A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendasDoDia() {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Histórico das vendas do dia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_vendasDoDia.isEmpty)
              const Text('Nenhuma venda registrada nesta data.')
            else
              ..._vendasDoDia.map((venda) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_formatarMoeda(venda.valorTotal)),
                  subtitle: Text(
                    'Pagamento: ${venda.formaPagamento}\n'
                    'Horário: ${_formatarHora(venda.dataVenda)}',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _NovaVendaScreen extends StatefulWidget {
  const _NovaVendaScreen({
    required this.usuario,
    required this.clientes,
    required this.produtos,
    required this.vendaRepository,
  });

  final Usuario usuario;
  final List<Cliente> clientes;
  final List<Produto> produtos;
  final VendaRepository vendaRepository;

  @override
  State<_NovaVendaScreen> createState() => _NovaVendaScreenState();
}

class _NovaVendaScreenState extends State<_NovaVendaScreen> {
  final TextEditingController _clienteBuscaController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController(
    text: '1',
  );

  final List<_ItemCarrinho> _carrinho = [];
  List<Cliente> _clientesEncontrados = [];

  Cliente? _clienteSelecionado;
  int? _idProdutoSelecionado;
  String _formaPagamento = 'Dinheiro';
  bool _finalizando = false;

  List<Cliente> get _clientes => widget.clientes;
  List<Produto> get _produtos => widget.produtos;

  int get _quantidade {
    return int.tryParse(_quantidadeController.text.trim()) ?? 1;
  }

  double get _totalCarrinho {
    return _carrinho.fold(0, (total, item) => total + item.subtotal);
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _buscarClientes(String termo) {
    final busca = termo.trim().toLowerCase();

    setState(() {
      if (_clienteSelecionado != null &&
          _clienteBuscaController.text.trim() != _clienteSelecionado!.nome) {
        _clienteSelecionado = null;
      }

      if (busca.isEmpty) {
        _clientesEncontrados = [];
        return;
      }

      _clientesEncontrados = _clientes.where((cliente) {
        return cliente.nome.toLowerCase().contains(busca);
      }).toList();
    });
  }

  void _selecionarCliente(Cliente cliente) {
    setState(() {
      _clienteSelecionado = cliente;
      _clienteBuscaController.text = cliente.nome;
      _clientesEncontrados = [];
    });

    FocusScope.of(context).unfocus();
  }

  void _limparBuscaCliente() {
    setState(() {
      _clienteSelecionado = null;
      _clienteBuscaController.clear();
      _clientesEncontrados = [];
    });
  }

  void _adicionarProduto() {
    if (_idProdutoSelecionado == null) {
      _mostrarMensagem('Selecione um produto.');
      return;
    }

    if (_quantidade < 1) {
      _mostrarMensagem('A quantidade deve ser maior que zero.');
      return;
    }

    final produto = _produtos.firstWhere(
      (item) => item.id == _idProdutoSelecionado,
    );

    final quantidadeJaNoCarrinho = _carrinho
        .where((item) => item.produto.id == produto.id)
        .fold<int>(0, (total, item) => total + item.quantidade);

    if (quantidadeJaNoCarrinho + _quantidade > produto.estoque) {
      _mostrarMensagem('Estoque insuficiente para ${produto.nomeProduto}.');
      return;
    }

    final indexExistente = _carrinho.indexWhere(
      (item) => item.produto.id == produto.id,
    );

    setState(() {
      if (indexExistente >= 0) {
        final itemAtual = _carrinho[indexExistente];
        _carrinho[indexExistente] = _ItemCarrinho(
          produto: produto,
          quantidade: itemAtual.quantidade + _quantidade,
        );
      } else {
        _carrinho.add(
          _ItemCarrinho(
            produto: produto,
            quantidade: _quantidade,
          ),
        );
      }

      _idProdutoSelecionado = null;
      _quantidadeController.text = '1';
    });
  }

  void _removerItem(int index) {
    setState(() {
      _carrinho.removeAt(index);
    });
  }

  Future<void> _finalizarVenda() async {
    if (_clienteSelecionado?.id == null) {
      _mostrarMensagem('Selecione um cliente.');
      return;
    }

    if (_carrinho.isEmpty) {
      _mostrarMensagem('Adicione pelo menos um produto à venda.');
      return;
    }

    if (widget.usuario.id == null) {
      _mostrarMensagem('Usuário logado inválido.');
      return;
    }

    setState(() {
      _finalizando = true;
    });

    try {
      final venda = Venda(
        dataVenda: DateTime.now(),
        valorTotal: _totalCarrinho,
        formaPagamento: _formaPagamento,
        idCliente: _clienteSelecionado!.id!,
        idUsuario: widget.usuario.id!,
      );

      final itens = _carrinho.map((item) {
        return ItemVenda(
          idProduto: item.produto.id!,
          quantidade: item.quantidade,
          subtotal: item.subtotal,
        );
      }).toList();

      await widget.vendaRepository.registrarVenda(
        venda: venda,
        itens: itens,
        produtos: _produtos,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      _mostrarMensagem('Erro ao finalizar venda: $e');
    } finally {
      if (mounted) {
        setState(() {
          _finalizando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _clienteBuscaController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: AppBar(
        title: const Text('Nova Venda'),
        backgroundColor: const Color(0xFF8FA55A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormularioVenda(),
            const SizedBox(height: 16),
            _buildCarrinho(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioVenda() {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _clienteBuscaController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Buscar cliente',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _clienteSelecionado != null ||
                        _clienteBuscaController.text.trim().isNotEmpty
                    ? IconButton(
                        onPressed: _limparBuscaCliente,
                        icon: const Icon(Icons.close),
                      )
                    : null,
              ),
              onChanged: _buscarClientes,
              onSubmitted: _buscarClientes,
            ),

            const SizedBox(height: 16),

            if (_clienteSelecionado != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cliente selecionado: ${_clienteSelecionado!.nome}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            else if (_clienteBuscaController.text.trim().isNotEmpty &&
                _clientesEncontrados.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nenhum cliente encontrado.'),
              ),

            if (_clientesEncontrados.isNotEmpty) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _clientesEncontrados.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cliente = _clientesEncontrados[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(cliente.nome),
                      onTap: () => _selecionarCliente(cliente),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            DropdownButtonFormField<int>(
              value: _idProdutoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Produto',
                border: OutlineInputBorder(),
              ),
              items: _produtos.map((produto) {
                return DropdownMenuItem<int>(
                  value: produto.id,
                  child: Text(
                    '${produto.nomeProduto} - ${_formatarMoeda(produto.preco)} '
                    '(Estoque: ${produto.estoque})',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _idProdutoSelecionado = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _adicionarProduto,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Produto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8FA55A),
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _formaPagamento,
              decoration: const InputDecoration(
                labelText: 'Forma de pagamento',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
                DropdownMenuItem(value: 'Cartão', child: Text('Cartão')),
                DropdownMenuItem(value: 'Pix', child: Text('Pix')),
              ],
              onChanged: (value) {
                setState(() {
                  _formaPagamento = value ?? 'Dinheiro';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarrinho() {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Itens da Venda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (_carrinho.isEmpty)
              const Text('Nenhum produto adicionado.')
            else
              ..._carrinho.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.produto.nomeProduto),
                  subtitle: Text(
                    'Qtd: ${item.quantidade} | '
                    'Subtotal: ${_formatarMoeda(item.subtotal)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removerItem(index),
                  ),
                );
              }),

            const Divider(),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ${_formatarMoeda(_totalCarrinho)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _finalizando ? null : _finalizarVenda,
                icon: _finalizando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_finalizando ? 'Finalizando...' : 'Finalizar Venda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8FA55A),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCarrinho {
  _ItemCarrinho({
    required this.produto,
    required this.quantidade,
  });

  final Produto produto;
  final int quantidade;

  double get subtotal => produto.preco * quantidade;
}
