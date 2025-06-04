import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_estoque_limpeza/data/model/historico_model.dart';

class MovimentacaoDetalhadaPage extends StatefulWidget {
  const MovimentacaoDetalhadaPage({super.key});

  @override
  State<MovimentacaoDetalhadaPage> createState() => _MovimentacaoDetalhadaPageState();
}

class _MovimentacaoDetalhadaPageState extends State<MovimentacaoDetalhadaPage> {
  final supabase = Supabase.instance.client;

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
    final response = await supabase
        .from('movimentacao')
        .select('''
          saida_data,
          saida,
          usuario:idusuario (matricula, nome, telefone),
          produto:idproduto (nome, quantidade)
        ''')
        .not('saida_data', 'is', null)
        .order('saida_data');

    return (response as List).map((map) {
      final usuario = map['usuario'] ?? {};
      final produto = map['produto'] ?? {};

      return HistoricoModel(
        matricula: usuario['matricula'] ?? '',
        nome: usuario['nome'] ?? '',
        telefone: usuario['telefone'] ?? '',
        saidaData: map['saida_data'] ?? '',
        saida: map['saida'] ?? 0,
        produto: produto['Nome'] ?? '',
        saldo: produto['Quantidade'] ?? 0,
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
