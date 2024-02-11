module cli_ctrler

import db.pg
import vweb
import json 

import models 
import dtos

pub struct ClienteCxt {
	vweb.Context
	db_handle vweb.DatabasePool[pg.DB] = unsafe { nil }
pub mut:
	db pg.DB
}


@['/:id/transacoes'; post]
pub fn (mut app ClienteCxt) post_transacao(id int) vweb.Result {
	transacao_dto := json.decode(dtos.TransacaoDto, app.req.data) or {
		app.set_status(400, '')
		return app.text('Failed to decode json, error: $err')
	}

	transacao := models.Transacao{
		id_cliente: id
		valor: transacao_dto.valor
		tipo: transacao_dto.tipo
		descricao: transacao_dto.descricao
	}

	sql app.db {
		insert transacao into models.Transacao
	}or {panic(err)}


	// return app.text('Id recebido $id')
	return app.json(transacao)
}

@['/:idRequest/extrato'; get]
pub fn (mut app ClienteCxt) get_extrato(idRequest i64) vweb.Result {
	clientes := sql app.db {
	select from models.Cliente where id == idRequest
	} or {panic(err)}

	if clientes == [] {
		app.set_status(404, '')
		return app.text("")
	}

	cliente := clientes[0]

	return app.json(cliente)
}