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
pub fn (mut app ClienteCxt) post_transacao(idRequest int) vweb.Result {
	transacao_dto := json.decode(dtos.TransacaoDto, app.req.data) or {
		app.set_status(400, '')
		return app.text('Failed to decode json, error: $err')
	}

	if !transacao_eh_valida(transacao_dto) {
		app.set_status(400, '')
		return app.text("")	
	}

	clientes := sql app.db {
		select from models.Cliente where id == idRequest
	} or {panic(err)}

	if clientes == [] {
		app.set_status(404, '')
		return app.text("")
	}

	cliente := clientes[0]

	mut saldo_cliente := i64(0)
	if transacao_dto.tipo == "c" {
		saldo_cliente = cliente.saldo + transacao_dto.valor 
	} 
	else if transacao_dto.tipo == "d"{
		saldo_cliente = cliente.saldo - transacao_dto.valor
		if cliente.limite + saldo_cliente < 0 {
			app.set_status(422, '')	
			return app.text("")
		}
	}
	else{
		app.set_status(404, '')	
		return app.text("")
	}

	sql app.db {
		update models.Cliente set saldo = saldo_cliente where id == idRequest
	} or {panic(err)}

	transacao := models.Transacao{
		id_cliente: idRequest
		valor: transacao_dto.valor
		tipo: transacao_dto.tipo
		descricao: transacao_dto.descricao
	}

	sql app.db {
		insert transacao into models.Transacao
	}or {panic(err)}

	transacao_response_dto := dtos.TransacaoResponseDto{
		limite: cliente.limite
		saldo: saldo_cliente
	}

	return app.json(transacao_response_dto)
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

fn transacao_eh_valida(transacao_dto dtos.TransacaoDto) bool{
	if transacao_dto.valor < 0 {
		return false
	}
	if transacao_dto.descricao.len > 10 {
		return false
	}
	return true
}
