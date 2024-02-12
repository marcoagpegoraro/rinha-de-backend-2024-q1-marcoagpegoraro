module main

import vweb
import db.pg

import models
import cli_ctrler

pub struct App {
	vweb.Context
	vweb.Controller
	db_handle vweb.DatabasePool[pg.DB] = unsafe { nil }
pub mut:
	db pg.DB
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
		models.Cliente{ id: 1 limite: 100000 saldo: 0},
		models.Cliente{ id: 2 limite: 80000 saldo: 0},
		models.Cliente{ id: 3 limite: 1000000 saldo: 0},
		models.Cliente{ id: 4 limite: 10000000 saldo: 0},
		models.Cliente{ id: 5 limite: 500000 saldo: 0},
	]

	for cliente in clientes{ 
		sql db {
			insert cliente into models.Cliente
		}!
	}

	app := &App{
		controllers: [
			vweb.controller('/clientes', cli_ctrler.ClienteCxt{
				db_handle: pool
			}),
		]
		db_handle: pool
	}

	vweb.run(app, 8080)
}

