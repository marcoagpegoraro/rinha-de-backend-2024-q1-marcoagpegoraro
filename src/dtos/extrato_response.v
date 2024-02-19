module dtos

pub struct ExtratoResponseDto {
pub:
	saldo SaldoDto
	ultimas_transacoes []TransacaoDto
}

pub struct SaldoDto {
pub:
	total i64
	data_extrato string
	limite i64
}

pub struct TransacaoDto {
pub:
	valor f64 @[required]
	tipo string @[required]
	descricao string @[required]
	realizada_em string
}
