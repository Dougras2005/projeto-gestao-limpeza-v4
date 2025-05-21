import 'package:app_estoque_limpeza/presentation/viewmodel/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_funcionario.dart';
import 'package:app_estoque_limpeza/presentation/pages/homepage_admin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final FocusNode _senhaFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    _senhaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final usuarioViewModel =
        Provider.of<UsuarioViewModel>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      final usuario = _usuarioController.text;
      final senha = _senhaController.text;

      final userProfile = await usuarioViewModel.loginUser(usuario, senha);

      if (!mounted) return;

      if (userProfile != null) {
        // Redireciona para a página apropriada com base no perfil
        if (userProfile.idperfil == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePageAdmin()),
          );
        } else if (userProfile.idperfil == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomePageFuncionario()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil desconhecido.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário ou senha incorretos.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.inventory_2_rounded,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Estoque, Limpeza e Copa',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça login para continuar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _usuarioController,
                label: 'Matrícula',
                icon: Icons.person_outline,
                onSubmitted: (_) => _senhaFocusNode.requestFocus(),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _senhaController,
                label: 'Senha',
                icon: Icons.lock_outline,
                obscureText: true,
                focusNode: _senhaFocusNode,
                onSubmitted: (_) => _loginUser(),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    FocusNode? focusNode,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      textInputAction:
          obscureText ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
