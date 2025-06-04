class Fornecedor {
  final int? idfornecedor;
  final String nome;
  final String endereco;
  final String telefone;
  final String cnpj;
  final String email;

  Fornecedor({
    this.idfornecedor,
    required this.nome,
    required this.endereco,
    required this.telefone,
    required this.cnpj,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'nome': nome,
      'endereco': endereco,
      'telefone': telefone,
      'cnpj': cnpj,
      'email': email,
    };

    if (idfornecedor != null) {
      map['idfornecedor'] = idfornecedor;
    }

    return map;
  }

  factory Fornecedor.fromMap(Map<String, dynamic> map) {
    return Fornecedor(
      idfornecedor: map['idfornecedor'] as int?,
      nome: map['nome'] as String,
      endereco: map['endereco'] as String,
      telefone: map['telefone'] as String,
      cnpj: map['cnpj'] as String,
      email: map['email'] as String,
    );
  }
}
