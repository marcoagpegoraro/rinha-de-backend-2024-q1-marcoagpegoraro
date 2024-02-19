module main

import vweb

import config
import controller

fn main(){
	pool := vweb.database_pool(handler: config.get_database_connection)

	app := &config.App{
		controllers: [
			vweb.controller('/clientes', controller.ClienteCxt{
				db_handle: pool
			}),
		]
	}

	vweb.run_at(app, vweb.RunParams{
		host: '0.0.0.0'
		port: 8080
		family: .ip
	}) or { panic(err) }
}

