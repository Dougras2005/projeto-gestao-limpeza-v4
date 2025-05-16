import 'dart:io';

import 'package:app_estoque_limpeza/presentation/pages/movimentacao_page.dart';
import 'package:flutter/material.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/produto_repositories.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  HomePageAdminState createState() => HomePageAdminState();
}

class HomePageAdminState extends State<HomePageAdmin> {
  final ProdutoRepositories _produtoRepository = ProdutoRepositories();
  final TextEditingController _searchController = TextEditingController();
  List<ProdutoModel> _produtos = [];
  List<ProdutoModel> _produtosFiltrados = [];
  bool _filtroAtivo = false; // Indica se o filtro de baixo estoque está ativo

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _searchController.addListener(_filtrarProdutos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

// Método para carregar os produtos cadastrados
  _carregarProdutos() async {
    final produtos = await _produtoRepository.getProduto();
    if (mounted) {
      setState(() {
        _produtos = produtos;
        _produtosFiltrados = produtos; // Inicialmente, exibe todos
      });

      // Print formatado para visualização dos produtos
      //   print('══════════════════ LISTA DE PRODUTOS ══════════════════');
      //   for (var i = 0; i < produtos.length; i++) {
      //     final produto = produtos[i];
      //     print('➤ Produto ${i + 1}:');
      //     print('   ID: ${produto.idMaterial}');
      //     print('   Código: ${produto.codigo}');
      //     print('   Nome: ${produto.nome}');
      //     print('   Quantidade: ${produto.quantidade}');
      //     print('   Validade: ${produto.validade ?? "N/A"}');
      //     print('   Local: ${produto.local}');
      //     print('   Tipo ID: ${produto.idtipo}');
      //     print('   Tipo: ${produto.tipoProduto ?? "N/A"}');
      //     print('   Fornecedor ID: ${produto.idfornecedor}');
      //     print('   Fornecedor: ${produto.nomeFornecedor ?? "N/A"}');
      //     print('   Entrada: ${produto.entrada}');
      //     print('──────────────────────────────────────────────');
      //   }
      //   print('Total de produtos: ${produtos.length}');
      //   print('════════════════════════════════════════════════');
    }
  }

  // Método para filtrar produtos pelo nome
  void _filtrarProdutos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _produtosFiltrados = _produtos
          .where((produto) => produto.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  // Método para filtrar produtos com baixo estoque
  void _filtrarBaixoEstoque() {
    setState(() {
      if (_filtroAtivo) {
        _produtosFiltrados = _produtos; // Retorna à lista completa
        _filtroAtivo = false;
      } else {
        _produtosFiltrados =
            _produtos.where((produto) => produto.quantidade <= 5).toList();
        _filtroAtivo = true;
      }
    });
  }

  // Método para filtrar produtos com baixo estoque
  // void _filtrarProdutosValidade() {
  //   setState(() {
  //     if (_filtroAtivo) {
  //       _produtosFiltrados = _produtos; // Retorna à lista completa
  //       _filtroAtivo = false;
  //     } else {
  //       _produtosFiltrados = _produtos.where((produto) => produto.validade <= 5).toList();
  //       _filtroAtivo = true;
  //     }
  //   });
  // }

  Future<void> exportProdutoToPdf() async {
    try {
      final resultado = await _produtoRepository.getProdutoAgrupado();
      final pdf = pw.Document();

      final headers = [
        'Código',
        'Produto',
        'Local',
        'Total Entrada',
        'Total Saída',
        'Saldo',
      ];

      final data = resultado.map((item) {
        return [
          item['Codigo']?.toString() ?? '',
          item['PRODUTO'] ?? '',
          item['LOCAL'] ?? '',
          item['TOTAL_ENTRADA']?.toString() ?? '0',
          item['TOTAL_SAIDA']?.toString() ?? '0',
          item['SALDO']?.toString() ?? '0',
        ];
      }).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => [
            pw.Text(
              'Relatório de Estoque',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              headerAlignment: pw.Alignment.center,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.center,
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1.5),
              },
              rowDecoration:
                  const pw.BoxDecoration(), // usado para zebradas abaixo
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
              // Linhas zebradas
              oddRowDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey100),
            ),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/relatorio_estoque.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(filePath);
    } catch (e) {
      throw Exception('Erro ao gerar o PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos Cadastrados'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_filtroAtivo ? Icons.list : Icons.warning,
                color: Colors.white),
            tooltip: _filtroAtivo ? 'Mostrar Todos' : 'Mostrar Baixo Estoque',
            onPressed: _filtrarBaixoEstoque,
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.menu, size: 36, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Menu Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.blueAccent),
                title: const Text('Cadastro de Produto'),
                onTap: () {
                  Navigator.pushNamed(context, '/cadastroProduto');
                },
              ),
              ListTile(
                leading: const Icon(Icons.business, color: Colors.blueAccent),
                title: const Text('Cadastro de Fornecedor'),
                onTap: () {
                  Navigator.pushNamed(context, '/cadastroFornecedor');
                },
              ),
              ListTile(
                leading: const Icon(Icons.supervised_user_circle,
                    color: Colors.blueAccent),
                title: const Text('Cadastro de Usuários'),
                onTap: () {
                  Navigator.pushNamed(context, '/cadastrodeusuario');
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.picture_as_pdf, color: Colors.blueAccent),
                title: const Text('Exportar PDF'),
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Gerando PDF...')),
                  );

                  try {
                    await exportProdutoToPdf();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                          content: Text('PDF salvo e aberto com sucesso!')),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Erro ao exportar PDF: $e')),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                title: const Text('Sair'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar Produto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _produtosFiltrados.isEmpty
                  ? const Center(child: Text('Nenhum produto encontrado'))
                  : ListView.builder(
                      itemCount: _produtosFiltrados.length,
                      itemBuilder: (context, index) {
                        final produto = _produtosFiltrados[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(
                              Icons.shopping_cart,
                              color: produto.quantidade <= 5
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                            title: Text(
                              produto.nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Quantidade: ${produto.quantidade}'),
                            onTap: () {
                              _showProdutoDetails(produto);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para mostrar os detalhes do produto e navegar para a página de detalhes
  // Função para mostrar os detalhes do produto e navegar para a página de detalhes
  void _showProdutoDetails(ProdutoModel produto) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdutoDetalhesPage(produto: produto),
      ),
    );
  }
}
