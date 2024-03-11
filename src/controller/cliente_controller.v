module controller

import db.pg
import vweb
import json
import arrays
import time
import math
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
		return app.text('Failed to decode json, error: ${err}')
	}

	if !transacao_eh_valida(transacao_dto) {
		app.set_status(422, '')
		return app.text('')
	}

	transacao_valor := i64(transacao_dto.valor)
	resultado := app.db.exec_param_many('SELECT * from update_balance($1, $2, $3)', [
		idRequest.str(),
		transacao_dto.tipo.str(),
		transacao_valor.str(),
	]) or { panic(err) }

	procedure_message_optional := resultado[0].vals[0] or { return app.server_error(500) }
	is_error_optional := resultado[0].vals[1] or { return app.server_error(500) }
	saldo_cliente_optional := resultado[0].vals[2] or { return app.server_error(500) }
	limite_cliente_optional := resultado[0].vals[3] or { return app.server_error(500) }

	procedure_message := procedure_message_optional.str()
	is_error := is_error_optional.str() == 't'
	saldo_cliente := (saldo_cliente_optional.str()).i64()
	limite_cliente := (limite_cliente_optional.str()).i64()

	if is_error {
		if procedure_message == 'Cliente não encontrado' {
			app.set_status(404, '')
		} else if procedure_message == 'Limite foi ultrapassado' {
			app.set_status(422, '')
		}
		return app.text('')
	}

	transacao := models.Transacao{
		id_cliente: idRequest
		valor: transacao_valor
		tipo: transacao_dto.tipo
		descricao: transacao_dto.descricao
		realizada_em: time.now().format_rfc3339()
	}

	sql app.db {
		insert transacao into models.Transacao
	} or { panic(err) }

	transacao_response_dto := dtos.TransacaoResponseDto{
		limite: limite_cliente
		saldo: saldo_cliente
	}

	return app.json(transacao_response_dto)
}

@['/:idRequest/extrato'; get]
pub fn (mut app ClienteCxt) get_extrato(idRequest i64) vweb.Result {
	clientes := sql app.db {
		select from models.Cliente where id == idRequest
	} or { panic(err) }

	if clientes.len == 0 {
		app.set_status(404, '')
		return app.text('')
	}

	cliente := clientes[0]

	transacoes := sql app.db {
		select from models.Transacao where id_cliente == idRequest order by realizada_em desc limit 10
	} or { panic(err) }

	transacoes_response_dto := arrays.map_indexed[models.Transacao, dtos.TransacaoDto](transacoes,
		fn (i int, e models.Transacao) dtos.TransacaoDto {
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

fn transacao_eh_valida(transacao_dto dtos.TransacaoDto) bool {
	if math.fmod(transacao_dto.valor, 1) != 0 {
		return false
	}
	if transacao_dto.valor < 0 {
		return false
	}
	if transacao_dto.tipo != 'c' && transacao_dto.tipo != 'd' {
		return false
	}
	if transacao_dto.descricao == '' || transacao_dto.descricao.len > 10 {
		return false
	}
	return true
}
