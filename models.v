module models

@[table: 'transacao']
pub struct Transacao {
pub:
	id        		int     @[primary; sql: serial]
	id_cliente		int
	tipo 			string
	valor 			i64
	descricao 		string
	realizada_em  	string
}

@[table: 'cliente']
pub struct Cliente {
pub:
	id        		int     @[primary; sql: serial]
	nome			string 
	limite			i64 
	saldo			i64 
	transacoes    []Transacao     @[fkey: 'id']
}

