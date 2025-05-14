class Fornecedor {
  final int? idfornecedor;
  final String nome;
  final String endereco;
  final String telefone; 
  final String cnpj;
  final String email;

  Fornecedor(
      {this.idfornecedor,
      required this.nome,
      required this.endereco,
      required this.telefone,
      required this.cnpj,
      required this.email,});

  Map<String, dynamic> toMap() {
    return {
      'idfornecedor': idfornecedor,
      'nome': nome,
      'endereco': endereco,
      'telefone': telefone,
      'cnpj': cnpj,
      'email': email,
    };
  }
}
