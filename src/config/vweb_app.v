module config

import vweb
import db.pg

pub struct App {
	vweb.Context
	vweb.Controller
	db_handle vweb.DatabasePool[pg.DB] = unsafe { nil }
pub mut:
	db pg.DB
}
