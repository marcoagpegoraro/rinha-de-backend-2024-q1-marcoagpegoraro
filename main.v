module main

import vweb
import db.pg
import json 
import models

struct App {
	vweb.Context
	db_handle vweb.DatabasePool[pg.DB] = unsafe { nil }
pub mut:
	db pg.DB
}

struct ExtratoResponseDto {
	saldo SaldoDto
	transacao []TransacaoDto
}

struct SaldoDto {
	total i64
	data_extrato string
	limite i64
}

struct TransacaoDto {
	valor i64
	tipo string
	descricao string
	realizada_em string
}



fn get_database_connection() pg.DB {
	return pg.connect(user: 'postgres', password: '12345', dbname: 'postgres') or { panic(err) }
}

fn main(){

	db := get_database_connection()

	pool := vweb.database_pool(handler: get_database_connection)

	sql db {
		create table models.Transacao
	}!
	sql db {
		create table models.Cliente
	}!

	db.exec('DELETE FROM cliente') or { panic(err) }
	db.exec('DELETE FROM transacao') or { panic(err) }
	
	clientes := [
		models.Cliente{ id: 1 limite: 100000 saldo_inicial: 0},
		models.Cliente{ id: 2 limite: 80000 saldo_inicial: 0},
		models.Cliente{ id: 3 limite: 1000000 saldo_inicial: 0},
		models.Cliente{ id: 4 limite: 10000000 saldo_inicial: 0},
		models.Cliente{ id: 5 limite: 500000 saldo_inicial: 0},
	]

	for cliente in clientes{ 
		sql db {
			insert cliente into models.Cliente
		}!
	}

	app := &App{
		db_handle: pool
	}

	vweb.run(app, 8080)
}

@['/clientes/:id/transacoes'; post]
pub fn (mut app App) post_transacao(id int) vweb.Result {
	transacao_dto := json.decode(TransacaoDto, app.req.data) or {
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

@['/clientes/:idRequest/extrato'; get]
pub fn (mut app App) get_extrato(idRequest i64) vweb.Result {
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