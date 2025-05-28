import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_estoque_limpeza/data/repositories/usuario_repository.dart';
import 'package:app_estoque_limpeza/presentation/pages/fornecedor_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/historico_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_admin.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_funcionario.dart';
import 'package:app_estoque_limpeza/presentation/pages/produto_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/login_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/usuarios_page.dart';
import 'package:app_estoque_limpeza/presentation/viewmodel/usuario_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UsuarioViewModel(UsuarioRepository()),
        ),
        // Adicione outros providers aqui, se necessário
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
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/cadastroProduto': (context) => const ProdutosPage(),
        '/cadastroFornecedor': (context) => const FornecedorPage(),
        '/cadastrodeusuario': (context) => const UsuarioPage(),
        '/ProdutoDetalhesPage': (context) => const HomePageAdmin(),
        '/HomePageFuncionario': (context) => const HomePageFuncionario(),
        '/Historico': (context) => const MovimentacaoDetalhadaPage(),
      },
    );
  }
}
