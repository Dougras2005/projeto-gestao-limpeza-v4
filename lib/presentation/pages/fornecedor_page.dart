import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:app_estoque_limpeza/data/repositories/fornecedor_repository.dart';
import 'package:app_estoque_limpeza/data/model/fornecedor_model.dart';

class FornecedorPage extends StatefulWidget {
  const FornecedorPage({super.key});

  @override
  FornecedorState createState() => FornecedorState();
}

class FornecedorState extends State<FornecedorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Máscaras
  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final FornecedorRepository _fornecedorRepository = FornecedorRepository();
  List<Fornecedor> _fornecedores = [];
  int? _fornecedorEmEdicaoId; // Null quando estiver cadastrando novo

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarFornecedores();
  }

  Future<void> _carregarFornecedores() async {
    final fornecedores = await _fornecedorRepository.getFornecedores();
    setState(() {
      _fornecedores = fornecedores;
    });
  }

  void _limparCampos() {
    _nomeController.clear();
    _enderecoController.clear();
    _telefoneController.clear();
    _cnpjController.clear();
    _emailController.clear();
    _fornecedorEmEdicaoId = null;
  }

  Future<void> _salvarFornecedor() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final fornecedor = Fornecedor(
          idfornecedor: _fornecedorEmEdicaoId,
          nome: _nomeController.text,
          endereco: _enderecoController.text,
          telefone: _telefoneController.text,
          cnpj: _cnpjController.text,
          email: _emailController.text,
        );

        if (_fornecedorEmEdicaoId == null) {
          // Cadastrar novo fornecedor
          await _fornecedorRepository.insertFornecedor(fornecedor);
        } else {
          // Atualizar fornecedor existente
          await _fornecedorRepository.updateFornecedor(fornecedor);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_fornecedorEmEdicaoId == null 
              ? 'Fornecedor cadastrado com sucesso!' 
              : 'Fornecedor atualizado com sucesso!')),
        );

        // Limpar campos e recarregar lista
        _limparCampos();
        await _carregarFornecedores();
        _tabController.animateTo(1); // Muda para a aba de listagem
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar fornecedor: $e')),
        );
      }
    }
  }

  Future<void> _excluirFornecedor(int id) async {
    try {
      await _fornecedorRepository.deleteFornecedor(id);
      await _carregarFornecedores();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fornecedor excluído com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir fornecedor: $e')),
      );
    }
  }

  void _editarFornecedor(Fornecedor fornecedor) {
    setState(() {
      _fornecedorEmEdicaoId = fornecedor.idfornecedor;
    });
    
    _nomeController.text = fornecedor.nome;
    _enderecoController.text = fornecedor.endereco;
    _telefoneController.text = fornecedor.telefone;
    _cnpjController.text = fornecedor.cnpj;
    _emailController.text = fornecedor.email;
    _tabController.animateTo(0); // Muda para a aba de cadastro/edição
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.blue[50],
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person_add), text: 'Cadastro'),
            Tab(icon: Icon(Icons.list), text: 'Listagem'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ABA DE CADASTRO/EDIÇÃO
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_fornecedorEmEdicaoId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Editando Fornecedor',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                _limparCampos();
                                setState(() {});
                              },
                              tooltip: 'Cancelar edição',
                            ),
                          ],
                        ),
                      ),
                    TextFormField(
                      controller: _nomeController,
                      decoration: inputDecoration.copyWith(labelText: 'Nome'),
                      validator: (value) => value?.isEmpty ?? true ? 'O nome é obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _enderecoController,
                      decoration: inputDecoration.copyWith(labelText: 'Endereço'),
                      validator: (value) => value?.isEmpty ?? true ? 'O endereço é obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cnpjController,
                      inputFormatters: [_cnpjFormatter],
                      decoration: inputDecoration.copyWith(labelText: 'CNPJ'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'O CNPJ é obrigatório';
                        final cleanedValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
                        return cleanedValue.length != 14 ? 'CNPJ deve ter 14 dígitos' : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      inputFormatters: [_telefoneFormatter],
                      decoration: inputDecoration.copyWith(labelText: 'Telefone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'O telefone é obrigatório';
                        final cleanedValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
                        return (cleanedValue.length != 10 && cleanedValue.length != 11) 
                            ? 'Telefone deve ter 10 ou 11 dígitos' : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: inputDecoration.copyWith(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'O email é obrigatório';
                        return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)
                            ? null : 'Email inválido';
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _salvarFornecedor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(_fornecedorEmEdicaoId == null ? 'Cadastrar' : 'Salvar Alterações'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // ABA DE LISTAGEM
          RefreshIndicator(
            onRefresh: _carregarFornecedores,
            child: _fornecedores.isEmpty
                ? const Center(child: Text('Nenhum fornecedor cadastrado'))
                : ListView.builder(
                    itemCount: _fornecedores.length,
                    itemBuilder: (context, index) {
                      final fornecedor = _fornecedores[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(fornecedor.nome),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CNPJ: ${fornecedor.cnpj}'),
                              Text('Telefone: ${fornecedor.telefone}'),
                              Text('Email: ${fornecedor.email}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _excluirFornecedor(fornecedor.idfornecedor!),
                          ),
                          onTap: () => _editarFornecedor(fornecedor),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                _limparCampos();
                _tabController.animateTo(0);
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}