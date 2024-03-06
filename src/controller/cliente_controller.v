module controller

import db.pg
import vweb
import json
import time

import models
import repository
import mapper
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

	if !transacao_dto.is_valid() {
		app.set_status(422, '')
		return app.text("")
	}

	transacao_valor := i64(transacao_dto.valor)
	resultado := app.db.exec_param_many('SELECT * from update_balance($1, $2, $3)', [idRequest.str(), transacao_dto.tipo.str(), transacao_valor.str()]) or { panic(err) }

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
		return app.text("")
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
	}or {panic(err)}


	transacao_response_dto := dtos.TransacaoResponseDto{
		limite: limite_cliente
		saldo: saldo_cliente
	}

	return app.json(transacao_response_dto)
}

@['/:id_cliente/extrato'; get]
pub fn (mut app ClienteCxt) get_extrato(id_cliente i64) vweb.Result {
	cliente := repository.get_client_by_id(app.db, id_cliente) or {
		app.set_status(404, '')
		return app.text("")
    }

	transacoes := repository.get_last_10_transactions_by_id_cliente(app.db, id_cliente) or {
        app.set_status(500, '')
		return app.text("")
    }

	extrato_response_dto := mapper.map_cliente_and_transacao_to_extrato(cliente, transacoes) or {
        app.set_status(500, '')
		return app.text("")
    }

	return app.json(extrato_response_dto)
}
