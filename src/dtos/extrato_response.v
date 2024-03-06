module dtos

import math

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

pub fn (dto TransacaoDto) is_valid() bool{
    if math.fmod(dto.valor, 1) != 0 {
		return false
	}
	if dto.valor < 0 {
		return false
	}
	if dto.tipo != "c" && dto.tipo != "d" {
		return false
	}
	if dto.descricao == "" || dto.descricao.len > 10 {
		return false
	}
	return true
}
