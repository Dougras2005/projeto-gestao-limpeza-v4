import 'package:app_estoque_limpeza/presentation/pages/users/movimentacao_page.dart';
import 'package:flutter/material.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/produto_repositories.dart';

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
        _produtosFiltrados = _produtos.where((produto) => produto.quantidade <= 5).toList();
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
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Cadastro de Produto'),
              onTap: () {
                Navigator.pushNamed(context, '/cadastroProduto');
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Cadastro de Fornecedor'),
              onTap: () {
                Navigator.pushNamed(context, '/cadastroFornecedor');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Lista de Produtos'),
              onTap: () {
                Navigator.pushNamed(context, '/ProdutoDetalhesPage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text('Cadastro de Usuários'),
              onTap: () {
                Navigator.pushNamed(context, '/cadastrodeusuario');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
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
                              color: produto.quantidade <= 5 ? Colors.red : Colors.blue,
                            ),
                            title: Text(
                              produto.nome,
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
