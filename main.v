module main

import vweb
import db.pg
import json 
// import time 

struct App {
	vweb.Context
	db_handle vweb.DatabasePool[pg.DB] = unsafe { nil }
pub mut:
	db pg.DB
}

@[table: 'transacao']
struct Transacao {
	id        		int     @[primary; sql: serial]
	id_cliente		int
	tipo 			string
	valor 			i64
	descricao 		string
	realizada_em  	string   @[default: 'CURRENT_TIME']
}


@[table: 'cliente']
struct Cliente {
	id        		int     @[primary; sql: serial]
	limite			i64 
	saldo_inicial	i64 
	transacoes    []Transacao     @[fkey: 'id']
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
		create table Transacao
	}!
	sql db {
		create table Cliente
	}!

	app := &App{
		db_handle: pool
	}

	vweb.run(app, 8080)
}

@['/clientes/:id/transacoes'; post]
pub fn (mut app App) post_transacao(id i64) vweb.Result {
	body := json.decode(TransacaoDto, app.req.data) or {
		app.set_status(400, '')
		return app.text('Failed to decode json, error: $err')
	}

	// app.db_handle.


	// return app.text('Id recebido $id')
	return app.json(body)
}

@['/clientes/:id/extrato'; get]
pub fn (mut app App) get_extrato(id i64) vweb.Result {
	return app.text('Id recebido $id')
}