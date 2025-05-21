import 'package:app_estoque_limpeza/data/model/movimentacao_model.dart';
import 'package:app_estoque_limpeza/presentation/viewmodel/produto_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/movimentacao_repository.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class ProdutoDetalhesPageFun extends StatefulWidget {
  final ProdutoModel produto;

  const ProdutoDetalhesPageFun({super.key, required this.produto});

  @override
  ProdutoDetalhesPageFunState createState() => ProdutoDetalhesPageFunState();
}

class ProdutoDetalhesPageFunState extends State<ProdutoDetalhesPageFun> {
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final MovimentacaoRepository _movimentacaoRepository = MovimentacaoRepository();
  final ProdutoViewModel _produtoViewModel = ProdutoViewModel();
  ProdutoModel? _produtoAtual;

  @override
  void initState() {
    super.initState();
    _initializeProdutoAtual();
  }

  void _initializeProdutoAtual() {
    _produtoAtual = ProdutoModel(
      idMaterial: widget.produto.idMaterial,
      codigo: widget.produto.codigo,
      nome: widget.produto.nome,
      quantidade: widget.produto.quantidade,
      validade: widget.produto.validade,
      local: widget.produto.local,
      idtipo: widget.produto.idtipo,
      idfornecedor: widget.produto.idfornecedor,
      entrada: widget.produto.entrada,
      nomeFornecedor: widget.produto.nomeFornecedor,
      tipoProduto: widget.produto.tipoProduto,
    );
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _registrarSaida() async {
    if (_produtoAtual == null) {
      _showDialog('Erro', 'Produto não foi carregado corretamente.');
      return;
    }

    final int quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final String data = _dataController.text;

    if (quantidade <= 0) {
      _showDialog('Erro', 'Informe uma quantidade válida maior que zero.');
      return;
    }

    if (data.isEmpty || !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(data)) {
      _showDialog('Erro', 'Informe uma data válida no formato DD/MM/AAAA.');
      return;
    }

    if (quantidade > _produtoAtual!.quantidade) {
      _showDialog('Erro', 'Quantidade insuficiente em estoque.');
      return;
    }

    try {
      final movimentacao = Movimentacao(
        entradaData: '',
        saidaData: data,
        idproduto: _produtoAtual!.idMaterial!,
        idusuario: 2,
        entrada: null,
        saida: quantidade,
      );

      await _movimentacaoRepository.insertMovimentacao(movimentacao);

      setState(() {
        _produtoAtual = ProdutoModel(
          idMaterial: _produtoAtual!.idMaterial,
          codigo: _produtoAtual!.codigo,
          nome: _produtoAtual!.nome,
          quantidade: _produtoAtual!.quantidade - quantidade,
          validade: _produtoAtual!.validade,
          local: _produtoAtual!.local,
          idtipo: _produtoAtual!.idtipo,
          idfornecedor: _produtoAtual!.idfornecedor,
          entrada: _produtoAtual!.entrada,
          nomeFornecedor: _produtoAtual!.nomeFornecedor,
          tipoProduto: _produtoAtual!.tipoProduto,
        );
      });

      await _produtoViewModel.updateProduto(_produtoAtual!);

      _quantidadeController.clear();
      _dataController.clear();

      _showDialog('Sucesso', 'Saída registrada com sucesso.\n'
          'Nova quantidade: ${_produtoAtual!.quantidade}');
    } catch (e) {
      _showDialog('Erro', 'Ocorreu um erro ao registrar a saída: $e');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).popAndPushNamed('/HomePageFuncionario'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_produtoAtual == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saída de Produto: ${_produtoAtual!.nome}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações do Produto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow('Código', _produtoAtual!.codigo),
                      _buildInfoRow('Nome', _produtoAtual!.nome),
                      _buildInfoRow('Quantidade em estoque', _produtoAtual!.quantidade.toString()),
                      _buildInfoRow('Local', _produtoAtual!.local),
                      if (_produtoAtual!.validade != null)
                        _buildInfoRow('Validade', _produtoAtual!.validade!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registrar Saída',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const Divider(),
                      const Text(
                        'Preencha os dados para registrar a saída do produto',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantidade para saída',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dataController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MaskedInputFormatter('##/##/####'),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Data da saída (DD/MM/YYYY)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _registrarSaida,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                          ),
                          child: const Text(
                            'Confirmar Saída',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.popAndPushNamed(context, '/HomePageFuncionario'),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
