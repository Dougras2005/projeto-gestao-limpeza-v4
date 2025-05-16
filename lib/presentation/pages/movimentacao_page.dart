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
  final MovimentacaoRepository _movimentacaoRepository =
      MovimentacaoRepository();
  final ProdutoViewModel _produtoViewModel = ProdutoViewModel();
  String _tipoMovimentacao = 'Entrada';
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

  Future<void> _registrarMovimentacao() async {
    if (_produtoAtual == null) {
      _showDialog('Erro', 'Produto não carregado.');
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

    if (_tipoMovimentacao == 'Saída' &&
        quantidade > _produtoAtual!.quantidade) {
      _showDialog('Erro', 'Quantidade insuficiente em estoque.');
      return;
    }

    try {
      final movimentacao = Movimentacao(
        entradaData: _tipoMovimentacao == 'Entrada' ? data : '',
        saidaData: _tipoMovimentacao == 'Saída' ? data : '',
        entrada: _tipoMovimentacao == 'Entrada' ? quantidade : null,
        saida: _tipoMovimentacao == 'Saída' ? quantidade : null,
        idproduto: _produtoAtual!.idMaterial!,
        idusuario: 1,
      );

      await _movimentacaoRepository.insertMovimentacao(movimentacao);

      // Atualiza produto com nova quantidade
      setState(() {
        _produtoAtual = ProdutoModel(
          idMaterial: _produtoAtual!.idMaterial,
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
          nomeFornecedor: _produtoAtual!.nomeFornecedor,
          tipoProduto: _produtoAtual!.tipoProduto,
        );
      });

      await _produtoViewModel.updateProduto(_produtoAtual!);

      _quantidadeController.clear();
      _dataController.clear();

      _showDialog('Sucesso', 'Movimentação registrada com sucesso.');
    } catch (e) {
      _showDialog('Erro', 'Erro ao registrar movimentação: $e');
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
    if (_produtoAtual == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Produto: ${_produtoAtual!.nome}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código: ${_produtoAtual!.codigo}',
                            style: const TextStyle(fontSize: 16)),
                        Text('Nome: ${_produtoAtual!.nome}',
                            style: const TextStyle(fontSize: 16)),
                        Text('Quantidade: ${_produtoAtual!.quantidade}',
                            style: const TextStyle(fontSize: 16)),
                        if (_produtoAtual!.validade != null)
                          Text('Validade: ${_produtoAtual!.validade}',
                              style: const TextStyle(fontSize: 16)),
                        Text('Local: ${_produtoAtual!.local}',
                            style: const TextStyle(fontSize: 16)),
                        Text('Fornecedor: ${_produtoAtual!.nomeFornecedor}',
                            style: const TextStyle(fontSize: 16)),
                        Text('Tipo: ${_produtoAtual!.tipoProduto}',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _tipoMovimentacao,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Movimentação',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Quantidade',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dataController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MaskedInputFormatter('##/##/####'),
                        ],
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Data (DD/MM/YYYY)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onFieldSubmitted: (_) => _registrarMovimentacao(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _registrarMovimentacao,
                          label: const Text(
                            'Registrar Movimentação',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.popAndPushNamed(
                            context, '/ProdutoDetalhesPage'),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
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
