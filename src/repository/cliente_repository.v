module repository

import db.pg

import models

pub fn get_client_by_id(db pg.DB, id_cliente i64) !models.Cliente {
	clientes := sql db {
	    select from models.Cliente where id == id_cliente
	} or {panic(err)}

	if clientes == [] {
		error('')
	}

	return clientes[0]
}
