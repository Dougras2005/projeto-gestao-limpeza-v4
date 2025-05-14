import 'package:app_estoque_limpeza/data/repositories/usuario_repositories.dart';
import 'package:app_estoque_limpeza/presentation/pages/fornecedor_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_admin.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_funcionario.dart';
import 'package:app_estoque_limpeza/presentation/pages/produto_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/users/login_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/usuarios_page.dart';
import 'package:app_estoque_limpeza/presentation/viewmodel/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
   runApp(
    MultiProvider(
      providers: [
         ChangeNotifierProvider(create: (context) => UsuarioViewModel(UsuarioRepository())),
        // Outros providers que você possa ter
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Estoque Limpeza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Definir a rota inicial como string
      routes: {
        '/': (context) => const LoginPage(), // Corrigir a referência da rota inicial
        '/cadastroProduto': (context) => const ProdutosPage(),
        '/cadastroFornecedor': (context) => const FornecedorPage(),
        '/cadastrodeusuario': (context) => const UsuariosPage(),
        '/ProdutoDetalhesPage':(context) => const HomePageAdmin(),
        '/HomePageFuncionario':(context) => const HomePageFuncionario(),
      },
    );
  }
}
