module models

@[table: 'transacao']
pub struct Transacao {
pub:
	id        		int     @[primary; sql: serial]
	id_cliente		int
	tipo 			string
	valor 			i64
	descricao 		string
	realizada_em  	string   @[default: 'CURRENT_TIME']
}

@[table: 'cliente']
pub struct Cliente {
pub:
	id        		int     @[primary; sql: serial]
	limite			i64 
	saldo			i64 
	transacoes    []Transacao     @[fkey: 'id']
}
