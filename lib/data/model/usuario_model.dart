class Usuario {
  final int? idusuario;
  final String matricula;
  final String nome;
  final String telefone;
  final String email;
  final int idperfil;
  final String senha;

  Usuario({
    this.idusuario,
    required this.matricula,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.idperfil,
    required this.senha,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic> {
      'matricula': matricula,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'idperfil': idperfil,
      'senha': senha,
    };

    if (idusuario != null) {
      map['idusuario'] = idusuario;
    }

    return map;

  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idusuario: map['idusuario'] as int?,
      matricula: map['matricula'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      idperfil: map['idperfil'] is int
          ? map['idperfil']
          : int.tryParse(map['idperfil'].toString()) ?? 0,
      senha: map['senha'] as String? ?? '',
    );
  }
}
