module models

@[table: 'transacao']
pub struct Transacao {
	id        		int     @[primary; sql: serial]
	id_cliente		int
	tipo 			string
	valor 			i64
	descricao 		string
	realizada_em  	string   @[default: 'CURRENT_TIME']
}

@[table: 'cliente']
pub struct Cliente {
	id        		int     @[primary; sql: serial]
	limite			i64 
	saldo_inicial	i64 
	transacoes    []Transacao     @[fkey: 'id']
}

