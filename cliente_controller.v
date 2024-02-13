module cli_ctrler

import db.pg
import vweb
import json 
import arrays 
import time

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
		app.set_status(422, '')
		return app.text('Failed to decode json, error: $err')
	}

	if !transacao_eh_valida(transacao_dto) {
		app.set_status(422, '')
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
	transacao_valor := i64(transacao_dto.valor) 
	if transacao_dto.tipo == "c" {
		saldo_cliente = cliente.saldo + transacao_valor 
	} 
	else if transacao_dto.tipo == "d"{
		saldo_cliente = cliente.saldo - transacao_valor
		if cliente.limite + saldo_cliente < 0 {
			app.set_status(422, '')	
			return app.text("")
		}
	}
	else{
		app.set_status(422, '')	
		return app.text("")
	}

	sql app.db {
		update models.Cliente set saldo = saldo_cliente where id == idRequest
	} or {panic(err)}

	transacao := models.Transacao{
		id_cliente: idRequest
		valor: transacao_valor
		tipo: transacao_dto.tipo
		descricao: transacao_dto.descricao
		realizada_em: time.now().format_rfc3339()
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

	transacoes := sql app.db {
		select from models.Transacao where id_cliente == idRequest order by realizada_em desc limit 10
	} or {panic(err)}

	transacoes_response_dto := arrays.map_indexed[models.Transacao, dtos.TransacaoDto](transacoes, fn (i int, e models.Transacao) dtos.TransacaoDto{
		return dtos.TransacaoDto{
			valor: e.valor
			tipo: e.tipo
			descricao: e.descricao
			realizada_em: e.realizada_em
		} 
	})

	extrato_response_dto := dtos.ExtratoResponseDto{
		saldo: dtos.SaldoDto{
			total: cliente.saldo
			data_extrato: time.now().format_rfc3339()
			limite: cliente.limite
		} 
		ultimas_transacoes: transacoes_response_dto
	}


	return app.json(extrato_response_dto)
}

fn transacao_eh_valida(transacao_dto dtos.TransacaoDto) bool{
	if transacao_dto.valor % 1 != 0 {
		return false
	}
	if transacao_dto.valor < 0 {
		return false
	}
	if  transacao_dto.descricao == "" || transacao_dto.descricao.len > 10 {
		return false
	}
	return true
}
