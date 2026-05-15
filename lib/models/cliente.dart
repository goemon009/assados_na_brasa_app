class Cliente {
    final int? id;
    final String nome;
    final String? cpf;
    final String? telefone;
    final String? endereco;
    final String status;

    Cliente({
        this.id,
        required this.nome,
        this.cpf,
        this.telefone,
        this.endereco,
        required this.status,
    });

    factory Cliente.fromMap(Map<String, dynamic> map) {
        return Cliente(
            id: map['id'],
            nome: map['nome'],
            cpf: map['cpf'],
            telefone: map['telefone'],
            endereco: map['endereco'],
            status: map['status'],
        );
    }

    Map<String, dynamic> toMap() {
        return {            
            'nome': nome,
            'cpf': cpf,
            'telefone': telefone,
            'endereco': endereco,
            'status': status,
        };
    }
}
