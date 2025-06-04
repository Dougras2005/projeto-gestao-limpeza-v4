import 'package:app_estoque_limpeza/api/database_helper.dart';
import 'package:app_estoque_limpeza/presentation/pages/movimentacao_page.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_estoque_limpeza/presentation/pages/fornecedor_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/historico_page.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_admin.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_funcionario.dart';
import 'package:app_estoque_limpeza/presentation/pages/produto_page.dart';

import 'package:app_estoque_limpeza/presentation/pages/usuarios_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseHelper.initialize();
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Erro ao conectar com o banco de dados: $e'),
          ),
        ),
      ),
    );
  }
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
        '/': (context) => const HomePageAdmin(),
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
