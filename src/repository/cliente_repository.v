module repository

import db.pg

import models

@[direct_array_access; inline]
pub fn get_client_by_id(db pg.DB, id_cliente i64) !models.Cliente {
	clientes := sql db {
	    select from models.Cliente where id == id_cliente
	}!

	if clientes == [] {
		error('')
	}

	return clientes[0]
}
