module models

@[table: 'transacao']
pub struct Transacao {
pub:
	id        		int     @[primary; sql: serial]
	id_cliente		int
	tipo 			string
	valor 			i64
	descricao 		string
	realizada_em  	string 	@[default: 'CURRENT_TIME'; sql_type: 'TIMESTAMP']
}
