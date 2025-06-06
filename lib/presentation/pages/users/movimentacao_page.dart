import 'package:app_estoque_limpeza/data/model/movimentacao_model.dart';
import 'package:app_estoque_limpeza/presentation/viewmodel/produto_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/movimentacao_repositories.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class ProdutoDetalhesPage extends StatefulWidget {
  final ProdutoModel produto;

  const ProdutoDetalhesPage({super.key, required this.produto});

  @override
  ProdutoDetalhesPageState createState() => ProdutoDetalhesPageState();
}

class ProdutoDetalhesPageState extends State<ProdutoDetalhesPage> {
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final MovimentacaoRepository _movimentacaoRepository = MovimentacaoRepository();
  final ProdutoViewModel _produtoViewModel = ProdutoViewModel();
  String _tipoMovimentacao = 'Entrada';
  ProdutoModel? _produtoAtual; // Removido o late e tornando nullable

  @override
  void initState() {
    super.initState();
    // Inicializa o produto atual imediatamente
    _initializeProdutoAtual();
  }

  void _initializeProdutoAtual() {
    _produtoAtual = ProdutoModel(
      idproduto: widget.produto.idproduto,
      codigo: widget.produto.codigo,
      nome: widget.produto.nome,
      quantidade: widget.produto.quantidade,
      validade: widget.produto.validade,
      local: widget.produto.local,
      idtipo: widget.produto.idtipo,
      idfornecedor: widget.produto.idfornecedor,
      entrada: widget.produto.entrada,
    );
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _registrarMovimentacao() async {
    // Adiciona verificação de null safety
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

    if (_tipoMovimentacao == 'Saída' && quantidade > _produtoAtual!.quantidade) {
      _showDialog('Erro', 'Quantidade insuficiente em estoque.');
      return;
    }

    try {
      final movimentacao = Movimentacao(
        entradaData: _tipoMovimentacao == 'Entrada' ? data : '',
        saidaData: _tipoMovimentacao == 'Saída' ? data : '',
        idproduto: _produtoAtual!.idproduto!,
        idusuario: 1,
      );

      await _movimentacaoRepository.insertMovimentacao(movimentacao);
      
      setState(() {
        _produtoAtual = ProdutoModel(
          idproduto: _produtoAtual!.idproduto,
          codigo: _produtoAtual!.codigo,
          nome: _produtoAtual!.nome,
          quantidade: _tipoMovimentacao == 'Entrada'
              ? _produtoAtual!.quantidade + quantidade
              : _produtoAtual!.quantidade - quantidade,
          validade: _produtoAtual!.validade,
          local: _produtoAtual!.local,
          idtipo: _produtoAtual!.idtipo,
          idfornecedor: _produtoAtual!.idfornecedor,
          entrada: _produtoAtual!.entrada,
        );
      });

      await _produtoViewModel.updateProduto(_produtoAtual!);

      _quantidadeController.clear();
      _dataController.clear();

      _showDialog('Sucesso', 'Movimentação registrada com sucesso.\n'
          'Nova quantidade: ${_produtoAtual!.quantidade}');
          Navigator.pushNamed(context, "/ProdutoDetalhesPage");
    } catch (e) {
      _showDialog('Erro', 'Ocorreu um erro ao registrar a movimentação: $e');
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adiciona verificação para caso o produto ainda não tenha sido inicializado
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
          'Detalhes do Produto: ${_produtoAtual!.nome}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
                      Text(
                        'Detalhes do Produto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const Divider(),
                      Text('Código: ${_produtoAtual!.codigo}'),
                      Text('Nome: ${_produtoAtual!.nome}'),
                      Text('Quantidade: ${_produtoAtual!.quantidade}'),
                      Text('Data de Entrada: ${_produtoAtual!.entrada}'),
                      if (_produtoAtual!.validade != null)
                        Text('Validade: ${_produtoAtual!.validade}'),
                      Text('Local: ${_produtoAtual!.local}'),
                      Text('Tipo: ${_produtoAtual!.idtipo}'),
                      Text('Fornecedor: ${_produtoAtual!.idfornecedor}'),
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
                        'Registrar Movimentação',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const Divider(),
                      DropdownButtonFormField<String>(
                        value: _tipoMovimentacao,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Movimentação',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        items: ['Entrada', 'Saída']
                            .map((tipo) => DropdownMenuItem(
                                  value: tipo,
                                  child: Text(tipo),
                                ))
                            .toList(),
                        onChanged: (valor) {
                          setState(() {
                            _tipoMovimentacao = valor!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantidade',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _dataController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MaskedInputFormatter('##/##/####'),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Data (DD/MM/YYYY)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _registrarMovimentacao,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Registrar Movimentação',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed:(){
                            Navigator.popAndPushNamed(context, "/ProdutoDetalhesPage");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Voltar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                          ],
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
}