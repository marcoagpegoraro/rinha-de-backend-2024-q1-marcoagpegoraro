module config

import db.pg

fn get_database_connection() pg.DB {
	return pg.connect_with_conninfo('host=db dbname=rinha user=admin password=123 port=5432') or {
		panic(err)
	}
}
