import 'package:app_estoque_limpeza/presentation/viewmodel/material_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/model/movimentacao_model.dart';
import 'package:app_estoque_limpeza/data/repositories/movimentacao_repository.dart';


class MaterialDetalhesPage extends StatefulWidget {
  final ProdutoModel material;                     // ← ERA ProdutoModel

  const MaterialDetalhesPage({super.key, required this.material});

  @override
  State<MaterialDetalhesPage> createState() => _MaterialDetalhesPageState();
}

class _MaterialDetalhesPageState extends State<MaterialDetalhesPage> {
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  final MovimentacaoRepository _movimentacaoRepository = MovimentacaoRepository();
  final ProdutoViewModel _produtoVM = ProdutoViewModel(); // troque se houver MaterialViewModel
  String _tipoMovimentacao = 'Entrada';
  late ProdutoModel _produtoAtual;                // ← ERA ProdutoModel?

  @override
  void initState() {
    super.initState();
    _produtoAtual = widget.material;               // cópia inicial
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  /* ---------------- REGISTRAR SAÍDA ---------------- */
  Future<void> _registrarSaida() async {
    final int quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final String data = _dataController.text;

    if (quantidade <= 0) {
      _showDialog('Erro', 'Informe uma quantidade válida maior que zero.');
      return;
    }
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(data)) {
      _showDialog('Erro', 'Informe a data no formato DD/MM/AAAA.');
      return;
    }
    if (quantidade > _produtoAtual.quantidade) {
      _showDialog('Erro', 'Quantidade insuficiente em estoque.');
      return;
    }

    try {
      final movimentacao = Movimentacao(
        entradaData: _tipoMovimentacao == 'Entrada' ? data : '',
        saidaData: _tipoMovimentacao == 'Saída' ? data : '',
        idproduto: _produtoAtual.idproduto!,
        idusuario: 1,
      );

      await _movimentacaoRepository.insertMovimentacao(movimentacao);
      
      setState(() {
        _produtoAtual = ProdutoModel(
          idproduto: _produtoAtual.idproduto,
          codigo: _produtoAtual.codigo,
          nome: _produtoAtual.nome,
          quantidade: _tipoMovimentacao == 'Entrada'
              ? _produtoAtual.quantidade + quantidade
              : _produtoAtual.quantidade - quantidade,
          validade: _produtoAtual.validade,
          local: _produtoAtual.local,
          idtipo: _produtoAtual.idtipo,
          idfornecedor: _produtoAtual.idfornecedor,
          entrada: _produtoAtual.entrada,
        );
      });
      await _produtoVM.updateMaterial(_produtoAtual); // troque se usar MaterialViewModel

      _quantidadeController.clear();
      _dataController.clear();

      _showDialog('Sucesso',
          'Saída registrada.\nNova quantidade: ${_produtoAtual.quantidade}');
    } catch (e) {
      _showDialog('Erro', 'Falha ao registrar saída: $e');
    }
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saída do Material: ${_produtoAtual.nome}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _cardInfo(),
              const SizedBox(height: 20),
              _cardSaida(),
            ],
          ),
        ),
      ),
    );
  }

  /* ---- cartão com info ---- */
  Widget _cardInfo() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informações do Material',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueGrey)),
              const Divider(),
              _row('Código', _produtoAtual.codigo),
              _row('Nome', _produtoAtual.nome),
              _row('Quantidade', _produtoAtual.quantidade.toString()),
              _row('Local', _produtoAtual.local),
              _row('Validade', _produtoAtual.validade.toString()),
            ],
          ),
        ),
      );

  /* ---- cartão para registrar saída ---- */
  Widget _cardSaida() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Registrar Saída',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueGrey)),
              const Divider(),
              const Text('Preencha para registrar a saída',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: _inputDeco('Quantidade para saída'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dataController,
                keyboardType: TextInputType.number,
                inputFormatters: [MaskedInputFormatter('##/##/####')],
                decoration: _inputDeco('Data de saída (DD/MM/AAAA)'),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _registrarSaida,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text('Confirmar Saída',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).popAndPushNamed('/HomePageFuncionario'),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.blueAccent)),
                ),
              ),
            ],
          ),
        ),
      );

  /* ---- helpers visuais ---- */
  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.blue[50],
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      );

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
                .popAndPushNamed('/HomePageFuncionario'),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
