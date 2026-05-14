import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormScreen({
    super.key,
    this.cliente,
  });

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final ClienteRepository _repository = ClienteRepository();

  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();

  String _status = 'ATIVO';
  bool _salvando = false;

  bool get _editando => widget.cliente != null;

  @override
  void initState() {
    super.initState();

    if (_editando) {
      final cliente = widget.cliente!;

      _nomeController.text = cliente.nome;
      _cpfController.text = cliente.cpf ?? '';
      _telefoneController.text = cliente.telefone ?? '';
      _enderecoController.text = cliente.endereco ?? '';
      _status = cliente.status;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final cliente = Cliente(
        id: widget.cliente?.id,
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _telefoneController.text.trim(),
        endereco: _enderecoController.text.trim(),
        status: _status,
      );

      if (_editando) {
        await _repository.atualizarCliente(cliente);
      } else {
        await _repository.cadastrarCliente(cliente);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Cliente atualizado com sucesso.'
                : 'Cliente cadastrado com sucesso.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar cliente: $e')),
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
    _cpfController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: AppBar(
        title: Text(_editando ? 'Editar Cliente' : 'Novo Cliente'),
        backgroundColor: const Color(0xFF4F4B46),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 4,
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
                            return 'Informe o nome do cliente.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _cpfController,
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _telefoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: 'Endereço',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
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
                                    : 'Cadastrar Cliente',
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