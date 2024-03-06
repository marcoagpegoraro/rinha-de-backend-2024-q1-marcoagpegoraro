module repository

import db.pg

import models

@[direct_array_access; inline]
pub fn get_last_10_transactions_by_id_cliente(db pg.DB, id_cliente i64) ![]models.Transacao {
    transacoes := sql db {
		select from models.Transacao where id_cliente == id_cliente order by realizada_em desc limit 10
	}!

	return transacoes
}
