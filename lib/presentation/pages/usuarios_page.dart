import 'dart:convert';

import 'package:app_estoque_limpeza/data/model/usuario_model.dart';
import 'package:app_estoque_limpeza/data/repositories/usuario_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  UsuarioState createState() => UsuarioState();
}

class UsuarioState extends State<UsuarioPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final List<String> _perfis = ['Administrador', 'Usuário'];
  String? _perfilSelecionado;

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  List<Usuario> _usuarios = [];
  int? _usuarioEmEdicaoId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarUsuarioes();
  }

  Future<void> _carregarUsuarioes() async {
    final usuarios = await _usuarioRepository.getUsuarios();
    setState(() {
      _usuarios = usuarios;
    });
  }

  void _limparCampos() {
    _nomeController.clear();
    _matriculaController.clear();
    _telefoneController.clear();
    _senhaController.clear();
    _emailController.clear();
    _perfilSelecionado = null;
    _usuarioEmEdicaoId = null;
  }

  Future<void> _salvarUsuario() async {
    if (_formKey.currentState!.validate()) {
      try {
        final bytes = utf8.encode(_senhaController.text);
        final senhaCriptografada = sha256.convert(bytes).toString();

        final novoUsuario = Usuario(
          idusuario: _usuarioEmEdicaoId,
          matricula: _matriculaController.text,
          nome: _nomeController.text,
          telefone: _telefoneController.text,
          email: _emailController.text,
          senha: senhaCriptografada,
          idperfil: _perfis.indexOf(_perfilSelecionado!) + 1,
        );

        if (_usuarioEmEdicaoId == null) {
          await _usuarioRepository.insertUsuario(novoUsuario);
        } else {
          await _usuarioRepository.updateUsuario(novoUsuario);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_usuarioEmEdicaoId == null
                  ? 'Usuário cadastrado com sucesso!'
                  : 'Usuário atualizado com sucesso!')),
        );

        await _carregarUsuarioes();
        _tabController.animateTo(1);
        _limparCampos();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar usuário: $e')),
        );
      }
    }
  }

 Future<void> _excluirusuario(int id) async {
  try {
    // Buscar o usuário que será excluído para poder restaurar, se necessário
    final usuarioExcluido = _usuarios.firstWhere((u) => u.idusuario == id);

    await _usuarioRepository.deleteUsuario(id);
    await _carregarUsuarioes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Usuário excluído com sucesso!'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.yellow,
          onPressed: () async {
            // Inserir novamente o usuário excluído
            await _usuarioRepository.insertUsuario(usuarioExcluido);
            await _carregarUsuarioes();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exclusão desfeita!')),
            );
          },
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao excluir usuário: $e')),
    );
  }
}


  void _editarusuario(Usuario usuario) {
    setState(() {
      _usuarioEmEdicaoId = usuario.idusuario;
      _nomeController.text = usuario.nome;
      _matriculaController.text = usuario.matricula;
      _telefoneController.text = usuario.telefone;
      _senhaController.text = '';
      _emailController.text = usuario.email;
      _perfilSelecionado = _perfis[usuario.idperfil - 1];
    });
    _tabController.animateTo(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _matriculaController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.blue[50],
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person_add), text: 'Cadastro'),
            Tab(icon: Icon(Icons.list), text: 'Listagem'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_usuarioEmEdicaoId != null)
                      Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Editando usuário',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              _limparCampos();
                              setState(() {});
                            },
                            tooltip: 'Cancelar edição',
                          ),
                        ],
                      ),
                    TextFormField(
                      controller: _nomeController,
                      decoration: inputDecoration.copyWith(labelText: 'Nome'),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'O nome é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _matriculaController,
                      decoration:
                          inputDecoration.copyWith(labelText: 'Matrícula'),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'A matrícula é obrigatória'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      decoration: inputDecoration.copyWith(labelText: 'Senha'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (_usuarioEmEdicaoId == null &&
                            (value?.isEmpty ?? true)) {
                          return 'A senha é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      inputFormatters: [_telefoneFormatter],
                      decoration:
                          inputDecoration.copyWith(labelText: 'Telefone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'O telefone é obrigatório';
                        }
                        final cleanedValue =
                            value!.replaceAll(RegExp(r'[^0-9]'), '');
                        return (cleanedValue.length != 10 &&
                                cleanedValue.length != 11)
                            ? 'Telefone deve ter 10 ou 11 dígitos'
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: inputDecoration.copyWith(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O email é obrigatório';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Informe um email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: inputDecoration.copyWith(labelText: 'Perfil'),
                      value: _perfilSelecionado,
                      items: _perfis
                          .map((perfil) => DropdownMenuItem(
                                value: perfil,
                                child: Text(perfil),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _perfilSelecionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione um perfil';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _salvarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(_usuarioEmEdicaoId == null
                            ? 'Cadastrar'
                            : 'Salvar Alterações'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _carregarUsuarioes,
            child: _usuarios.isEmpty
                ? const Center(child: Text('Nenhum usuário cadastrado'))
                : ListView.builder(
                    itemCount: _usuarios.length,
                    itemBuilder: (context, index) {
                      final usuario = _usuarios[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(usuario.nome),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nome: ${usuario.nome}'),
                              Text('Telefone: ${usuario.telefone}'),
                              Text('Email: ${usuario.email}'),
                              Text('Matrícula: ${usuario.matricula}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _excluirusuario(usuario.idusuario!),
                          ),
                          onTap: () => _editarusuario(usuario),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () {
                _limparCampos();
                _tabController.animateTo(0);
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
