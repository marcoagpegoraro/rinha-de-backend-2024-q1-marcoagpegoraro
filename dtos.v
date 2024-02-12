module dtos

pub struct ExtratoResponseDto {
pub:
	saldo SaldoDto
	transacao []TransacaoDto
}

pub struct SaldoDto {
pub:
	total i64
	data_extrato string
	limite i64
}

pub struct TransacaoDto {
pub:
	valor i64
	tipo string
	descricao string
	realizada_em string
}

pub struct TransacaoResponseDto {
pub:
	limite 	i64
	saldo 	i64
}
