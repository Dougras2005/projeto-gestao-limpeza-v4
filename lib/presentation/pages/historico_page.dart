import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_estoque_limpeza/core/database_helper.dart';
import 'package:app_estoque_limpeza/data/model/historico_model.dart';

class MovimentacaoDetalhadaPage extends StatefulWidget {
  const MovimentacaoDetalhadaPage({super.key});

  @override
  State<MovimentacaoDetalhadaPage> createState() => _MovimentacaoDetalhadaPageState();
}

class _MovimentacaoDetalhadaPageState extends State<MovimentacaoDetalhadaPage> {
  Future<List<HistoricoModel>> _movimentacoesFuture = Future.value([]);
  List<HistoricoModel> _movimentacoes = [];

  DateTimeRange? _dataSelecionada;
  final DateFormat formatoDataBanco = DateFormat('dd/MM/yyyy', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _carregarMovimentacoes();
  }

  Future<void> _carregarMovimentacoes() async {
    final movimentacoes = await getMovimentacoesDetalhadas();
    setState(() {
      _movimentacoes = movimentacoes;
      _movimentacoesFuture = Future.value(movimentacoes);
    });
  }

  Future<List<HistoricoModel>> getMovimentacoesDetalhadas() async {
    final db = await DatabaseHelper.initDb();
    final List<Map<String, Object?>> results = await db.rawQuery('''
      SELECT
        u.matricula,
        u.nome,
        u.telefone,
        m.saida_data,
        m.saida,
        p.Nome AS produto,
        p.Quantidade AS saldo
      FROM movimentacao m
      JOIN usuario u ON u.idusuario = m.idusuario
      JOIN produto p ON p.idproduto = m.idmaterial
      WHERE saida_data <> ''
      ORDER BY m.saida_data
    ''');

    return results.map((map) {
      return HistoricoModel(
        matricula: map['matricula'] as String,
        nome: map['nome'] as String,
        telefone: map['telefone'] as String,
        saidaData: map['saida_data'] as String,
        saida: (map['saida'] as int?) ?? 0,
        produto: map['produto'] as String,
        saldo: (map['saldo'] as int?) ?? 0,
      );
    }).toList();
  }

  void _filtrarPorData() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dataSelecionada,
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        _dataSelecionada = picked;
        _movimentacoesFuture = Future.value(
          _movimentacoes.where((mov) {
            try {
              final data = formatoDataBanco.parse(mov.saidaData);
              return data.isAfter(picked.start.subtract(const Duration(days: 1))) &&
                     data.isBefore(picked.end.add(const Duration(days: 1)));
            } catch (_) {
              return false;
            }
          }).toList(),
        );
      });
    }
  }

  void _limparFiltro() {
    setState(() {
      _dataSelecionada = null;
      _movimentacoesFuture = Future.value(_movimentacoes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Movimentações'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filtrar por data',
            onPressed: _filtrarPorData,
          ),
          if (_dataSelecionada != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpar filtro',
              onPressed: _limparFiltro,
            ),
        ],
      ),
      body: FutureBuilder<List<HistoricoModel>>(
        future: _movimentacoesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final movimentacoes = snapshot.data ?? [];

          if (movimentacoes.isEmpty) {
            return const Center(child: Text('Nenhuma movimentação encontrada'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: movimentacoes.length,
            itemBuilder: (context, index) {
              final mov = movimentacoes[index];

              String dataFormatada;
              try {
                final data = formatoDataBanco.parse(mov.saidaData);
                dataFormatada = formatoDataBanco.format(data);
              } catch (_) {
                dataFormatada = 'Data inválida';
              }

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mov.nome,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Matrícula: ${mov.matricula}'),
                      Text('Telefone: ${mov.telefone}'),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Produto: ${mov.produto}'),
                          Text('Saldo: ${mov.saldo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Saída: ${mov.saida}'),
                          Text('Data: $dataFormatada'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
