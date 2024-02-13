module clictrller

import vweb
import vwebconfig

type App = vwebconfig.App

@['/clientes/:id/transacoes'; post]
pub fn (mut app App) post_transacao(id int) vweb.Result {
	transacao_dto := json.decode(TransacaoDto, app.req.data) or {
		app.set_status(400, '')
		return app.text('Failed to decode json, error: $err')
	}

	transacao := Transacao{
		id_cliente: id
		valor: transacao_dto.valor
		tipo: transacao_dto.tipo
		descricao: transacao_dto.descricao
	}

	sql app.db {
		insert transacao into Transacao
	}or { []Transacao{} }

	return app.json(transacao)
}

@['/clientes/:idRequest/extrato'; get]
pub fn (mut app App) get_extrato(idRequest i64) vweb.Result {
	clientes := sql app.db {
	select from Cliente where id == idRequest
	} or {[]Cliente{}}

	if clientes == [] {
		app.set_status(404, '')
		return app.text("")
	}

	cliente := clientes[0]

	return app.json(cliente)
}