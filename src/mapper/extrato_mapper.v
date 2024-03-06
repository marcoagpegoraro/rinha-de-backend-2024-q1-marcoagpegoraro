module mapper

import time
import arrays

import dtos
import models

pub fn map_cliente_and_transacao_to_extrato(cliente models.Cliente, transacoes []models.Transacao) !dtos.ExtratoResponseDto {
	transacoes_response_dto := arrays.map_indexed[models.Transacao, dtos.TransacaoDto](transacoes, fn (i int, e models.Transacao) dtos.TransacaoDto{
		return dtos.TransacaoDto{
			valor: e.valor
			tipo: e.tipo
			descricao: e.descricao
			realizada_em: e.realizada_em
		}
	})

	return dtos.ExtratoResponseDto{
		saldo: dtos.SaldoDto{
			total: cliente.saldo
			data_extrato: time.now().format_rfc3339()
			limite: cliente.limite
		}
		ultimas_transacoes: transacoes_response_dto
	}
}
