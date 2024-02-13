CREATE TABLE cliente (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(30) NOT NULL,
  limite INTEGER NOT NULL,
  saldo INTEGER NOT NULL
);

CREATE TABLE transacao (
    id SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    tipo CHAR(1) NOT NULL,
    valor INTEGER NOT NULL,
    descricao VARCHAR(10) NOT NULL,
    realizada_em VARCHAR(30) NOT NULL,
    CONSTRAINT fk_clientes_transacoes_id
        FOREIGN KEY (id_cliente) REFERENCES cliente(id)
);

CREATE INDEX IF NOT EXISTS idx_transacoes_id_desc ON cliente(id desc);
CREATE INDEX IF NOT EXISTS idx_transacoes_id_desc ON transacao(id desc);



CREATE OR REPLACE FUNCTION update_balance(id_cliente INT, tipo_transacao CHAR(1), valor_transacao NUMERIC) RETURNS TEXT AS $$
DECLARE
    client_record RECORD;
    limite_cliente NUMERIC;
    saldo_cliente NUMERIC;
    return_message TEXT;
BEGIN
	SELECT * INTO client_record FROM cliente WHERE id = id_cliente;
    IF NOT FOUND THEN
        return_message := 'Cliente não encontrado';
        RETURN return_message;
    END IF;
    limite_cliente := client_record.limite;
    IF tipo_transacao = 'c' THEN
    	saldo_cliente := client_record.saldo + valor_transacao;
    ELSIF tipo_transacao = 'd' THEN
        saldo_cliente := client_record.saldo - valor_transacao;
        IF limite_cliente + saldo_cliente < 0 THEN
            return_message := 'Limite foi ultrapassado';
            RETURN return_message;
        END IF;
  	END IF;
  	UPDATE cliente SET saldo = saldo_cliente WHERE id = id_cliente;
    return_message := 'Saldo do cliente atualizado com sucesso';
	return return_message
 END;
$$ LANGUAGE plpgsql;

INSERT INTO cliente (id, nome, limite, saldo) VALUES
	(1, 'o barato sai caro', 1000 * 100, 0),
	(2, 'zan corp ltda', 800 * 100, 0),
	(3, 'les cruders', 10000 * 100, 0),
	(4, 'padaria joia de cocaia', 100000 * 100, 0),
	(5, 'kid mais', 5000 * 100, 0);
