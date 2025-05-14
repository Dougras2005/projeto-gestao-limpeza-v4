class Movimentacao {
  final int? idmovimentacao;
  final String entradaData;
  final String saidaData;
  final int? entrada; // Novo campo inteiro
  final int? saida;   // Novo campo inteiro
  final int idproduto;
  final int idusuario;

  Movimentacao({
    this.idmovimentacao,
    required this.entradaData,
    required this.saidaData,
    this.entrada,
    this.saida,
    required this.idproduto,
    required this.idusuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'idmovimentacao': idmovimentacao,
      'entrada_data': entradaData,
      'saida_data': saidaData,
      'entrada': entrada,
      'saida': saida,
      'idmaterial': idproduto,
      'idusuario': idusuario,
    };
  }
}