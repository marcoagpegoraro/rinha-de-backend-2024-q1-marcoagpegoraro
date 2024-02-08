module main

import vweb

struct App {
	vweb.Context
}

struct Teste {
	nome string
	idade i16
}

fn main(){
	app := App{}
	vweb.run(app, 8080)
}

@['/']
pub fn (mut app App) teste() vweb.Result {
	teste := Teste{
		nome : "Marco"
		idade : 24
	}
	return app.json(teste)
}


@['/clientes/:id/transacoes'; post]
pub fn (mut app App) post_transacao(id i64) vweb.Result {
	return app.text('Id recebido $id')
}

@['/clientes/:id/extrato'; get]
pub fn (mut app App) get_extrato(id i64) vweb.Result {
	return app.text('Id recebido $id')
}