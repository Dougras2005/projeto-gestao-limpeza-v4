import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/produto_repository.dart';
import 'package:app_estoque_limpeza/presentation/pages/movimentacao_page.dart';
import 'package:flutter/material.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  HomePageAdminState createState() => HomePageAdminState();
}

class HomePageAdminState extends State<HomePageAdmin> {
  final ProdutoRepository _materialRepository = ProdutoRepository();
  final TextEditingController _searchController = TextEditingController();
  List<ProdutoModel> _materiais = [];
  List<ProdutoModel> _materiaisFiltrados = [];
  bool _filtroAtivo = false;

  @override
  void initState() {
    super.initState();
    _carregarMateriais();
    _searchController.addListener(_filtrarMateriais);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarMateriais() async {
    final materiais = await _materialRepository.getProduto();
    if (mounted) {
      setState(() {
        _materiais = materiais;
        _materiaisFiltrados = materiais;
      });
    }
  }

  void _filtrarMateriais() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _materiaisFiltrados = _materiais
          .where((m) => m.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  void _filtrarBaixoEstoque() {
    setState(() {
      if (_filtroAtivo) {
        _materiaisFiltrados = _materiais;
        _filtroAtivo = false;
      } else {
        _materiaisFiltrados =
            _materiais.where((m) => m.quantidade <= 5).toList();
        _filtroAtivo = true;
      }
    });
  }

  // Future<void> exportProdutoToPdf() async {
  //   try {
  //     final materiais = await _materialRepository.getMateriais();
  //     final pdf = pw.Document();

  //     final headers = [
  //       'ID',
  //       'Produto',
  //       'Local',
  //       'Total Entrada',
  //       'Total Saída',
  //       'Saldo',
  //     ];

  //     final data = materiais.map((m) {
  //       return [
  //         m.idMaterial.toString(),
  //         m.nome,
  //         m.local ?? '',
  //         m.entrada.toString() ?? '0',
  //         m.toString() ?? '0',
  //         m.quantidade.toString(),
  //       ];
  //     }).toList();

  //     pdf.addPage(
  //       pw.MultiPage(
  //         pageFormat: PdfPageFormat.a4,
  //         build: (pw.Context context) => [
  //           pw.Text(
  //             'Relatório de Estoque',
  //             style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
  //           ),
  //           pw.SizedBox(height: 16),
  //           pw.TableHelper.fromTextArray(
  //             headers: headers,
  //             data: data,
  //             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
  //             cellStyle: const pw.TextStyle(fontSize: 9),
  //             cellAlignment: pw.Alignment.center,
  //             columnWidths: {
  //               0: const pw.FlexColumnWidth(1.2),
  //               1: const pw.FlexColumnWidth(2.5),
  //               2: const pw.FlexColumnWidth(2),
  //               3: const pw.FlexColumnWidth(1.5),
  //               4: const pw.FlexColumnWidth(1.5),
  //               5: const pw.FlexColumnWidth(1.5),
  //             },
  //             cellAlignments: {
  //               0: pw.Alignment.centerLeft,
  //               1: pw.Alignment.centerLeft,
  //               2: pw.Alignment.centerLeft,
  //               3: pw.Alignment.centerRight,
  //               4: pw.Alignment.centerRight,
  //               5: pw.Alignment.centerRight,
  //             },
  //             oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
  //           ),
  //         ],
  //       ),
  //     );

  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath = '${directory.path}/relatorio_estoque.pdf';
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //     await OpenFile.open(filePath);
  //   } catch (e) {
  //     throw Exception('Erro ao gerar o PDF: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos Cadastrados'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_filtroAtivo ? Icons.list : Icons.warning, color: Colors.white),
            tooltip: _filtroAtivo ? 'Mostrar Todos' : 'Mostrar Baixo Estoque',
            onPressed: _filtrarBaixoEstoque,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Text('Menu Principal',
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blueAccent),
              title: const Text('Cadastro de Produto'),
              onTap: () => Navigator.pushNamed(context, '/cadastroProduto'),
            ),
            ListTile(
              leading: const Icon(Icons.business, color: Colors.blueAccent),
              title: const Text('Cadastro de Fornecedor'),
              onTap: () => Navigator.pushNamed(context, '/cadastroFornecedor'),
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle, color: Colors.blueAccent),
              title: const Text('Cadastro de Usuários'),
              onTap: () => Navigator.pushNamed(context, '/cadastrodeusuario'),
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined, color: Colors.blueAccent),
              title: const Text('Histórico das Movimentações'),
              onTap: () => Navigator.pushNamed(context, '/Historico'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.blueAccent),
              title: const Text('Exportar PDF'),
              onTap: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Gerando PDF...')),
                );
                // try {
                //   await exportProdutoToPdf();
                //   scaffoldMessenger.showSnackBar(
                //     const SnackBar(content: Text('PDF salvo e aberto com sucesso!')),
                //   );
                // } catch (e) {
                //   scaffoldMessenger.showSnackBar(
                //     SnackBar(content: Text('Erro ao exportar PDF: $e')),
                //   );
                // }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: const Text('Sair'),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ],
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
              child: _materiaisFiltrados.isEmpty
                  ? const Center(child: Text('Nenhum produto encontrado'))
                  : ListView.builder(
                      itemCount: _materiaisFiltrados.length,
                      itemBuilder: (context, index) {
                        final material = _materiaisFiltrados[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(
                              Icons.shopping_cart,
                              color: material.quantidade <= 5
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                            title: Text(material.nome,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Quantidade: ${material.quantidade}'),
                            onTap: () {
                              _showMaterialDetails(material);
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

  void _showMaterialDetails(ProdutoModel material) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdutoDetalhesPage(produto: material),
      ),
    );
  }
}