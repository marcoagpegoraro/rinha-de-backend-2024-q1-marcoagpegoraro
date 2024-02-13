module main

import vweb
import db.pg

import cli_ctrler

pub struct App {
	vweb.Context
	vweb.Controller
	db_handle vweb.DatabasePool[pg.DB] = unsafe { nil }
pub mut:
	db pg.DB
}


fn get_database_connection() pg.DB {
	return pg.connect_with_conninfo("host=192.168.0.2 dbname=rinha user=admin password=123 port=5432") or { panic(err) }
}

fn main(){
	pool := vweb.database_pool(handler: get_database_connection)

	app := &App{
		controllers: [
			vweb.controller('/clientes', cli_ctrler.ClienteCxt{
				db_handle: pool
			}),
		]
		db_handle: pool
	}

	vweb.run_at(app, vweb.RunParams{
		host: '0.0.0.0'
		port: 8080
		family: .ip
	}) or { panic(err) }
}

