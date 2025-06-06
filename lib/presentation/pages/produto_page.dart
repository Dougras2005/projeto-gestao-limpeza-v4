import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/fornecedor_repository.dart';
import 'package:app_estoque_limpeza/data/repositories/produto_repository.dart';
import 'package:app_estoque_limpeza/data/repositories/tipo_repository.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  ProdutosState createState() => ProdutosState();
}

class ProdutosState extends State<ProdutosPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _fornecedorCustomController = TextEditingController();
  final TextEditingController _tipoCustomController = TextEditingController();
  final TextEditingController _dataEntradaController = TextEditingController();
  final TextEditingController _vencimentoController = TextEditingController();

  String? _tipo;
  String? _fornecedor;
  List<String> _fornecedores = [];
  List<String> _tipos = [];

  final ProdutoRepository _produtoRepository = ProdutoRepository();
  final TipoRepository _tipoRepository = TipoRepository();
  final FornecedorRepository _fornecedorRepository = FornecedorRepository();

  @override
  void initState() {
    super.initState();
    _listaDeFornecedores();
    _listaTipo();
    _dataEntradaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _listaDeFornecedores() async {
    try {
      List<String> fornecedores = await _fornecedorRepository.getNomesFornecedores();
      if (mounted) {
        setState(() {
          _fornecedores = fornecedores;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar fornecedores: $e')),
        );
      }
    }
  }

  Future<void> _listaTipo() async {
    try {
      List<String> tipo = await _tipoRepository.getNomesTipo();
      if (mounted) {
        setState(() {
          _tipos = tipo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar tipo: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _cadastroProduto() async {
    if (_formKey.currentState?.validate() ?? false) {
      // try {
        if (_tipo == null || _tipo!.isEmpty) {
          throw Exception('O tipo do produto não pode ser nulo.');
        }
        if (_fornecedor == null || _fornecedor!.isEmpty) {
          throw Exception('O fornecedor do produto não pode ser nulo.');
        }

        final idTipo = await _tipoRepository.getIdByTipo(_tipo!);
        final idFornecedor = await _fornecedorRepository.getIdByFornecedor(_fornecedor!);

        final produto = ProdutoModel(
  codigo: _codigoController.text,
  nome: _nomeController.text,
  quantidade: int.parse(_quantidadeController.text),
  validade: _vencimentoController.text.isNotEmpty
      ? DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_vencimentoController.text))
      : null,
  local: _localController.text,
  idtipo: idTipo!,
  idfornecedor: idFornecedor!,
  entrada: _dataEntradaController.text.isNotEmpty
      ? DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_dataEntradaController.text))
      : '',
);


        await _produtoRepository.insertProduto(produto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto cadastrado com sucesso!')),
          );

          _codigoController.clear();
          _nomeController.clear();
          _quantidadeController.clear();
          _localController.clear();
          _fornecedorCustomController.clear();
          _tipoCustomController.clear();
          _dataEntradaController.clear();
          _vencimentoController.clear();
          setState(() {
            _tipo = null;
            _fornecedor = null;
          });

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePageAdmin()),
            (Route<dynamic> route) => false,
          );
        }
      // // } catch (e, stackTrace) {
      //   debugPrint('Erro: $e\n$stackTrace');
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Erro ao cadastrar material: $e')),
      //     );
      //   }
      // }
    }
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
        title: const Text('Cadastro de Produtos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _codigoController,
                  decoration: inputDecoration.copyWith(labelText: 'Código'),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O código é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomeController,
                  decoration: inputDecoration.copyWith(labelText: 'Nome'),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantidadeController,
                  decoration: inputDecoration.copyWith(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A quantidade é obrigatória';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, insira um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _localController,
                  decoration: inputDecoration.copyWith(labelText: 'Local'),
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O local é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: inputDecoration.copyWith(labelText: 'Tipo'),
                  items: _tipos
                      .map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(
                              tipo,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipo = value;
                      if (value != "Perecivel") {
                        _vencimentoController.clear();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O tipo é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_tipo == "Outro")
                  TextFormField(
                    controller: _tipoCustomController,
                    decoration:
                        inputDecoration.copyWith(labelText: 'Descreva o Tipo'),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Descreva o tipo';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _fornecedor,
                  decoration: inputDecoration.copyWith(labelText: 'Fornecedor'),
                  items: _fornecedores
                      .map((fornecedor) => DropdownMenuItem(
                            value: fornecedor,
                            child: Text(
                              fornecedor,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _fornecedor = value;
                    }); 
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O fornecedor é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dataEntradaController,
                  decoration:
                      inputDecoration.copyWith(labelText: 'Data de Entrada'),
                  readOnly: true,
                  onTap: () => _selectDate(context, _dataEntradaController),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A data de entrada é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_tipo == "Perecivel")
                  TextFormField(
                    controller: _vencimentoController,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Data de Validade',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _vencimentoController),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (_tipo == "Perecível" && (value == null || value.isEmpty)) {
                        return 'A data de validade é obrigatória para produtos perecíveis';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _cadastroProduto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}