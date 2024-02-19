module models

@[table: 'cliente']
pub struct Cliente {
pub:
	id        		int     @[primary; sql: serial]
	nome			string
	limite			i64
	saldo			i64
	transacoes    []Transacao     @[fkey: 'id']
}

