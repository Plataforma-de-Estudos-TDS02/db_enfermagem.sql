-- =========================================================
-- BANCO DE DADOS: db_calculos_enfermagem
-- =========================================================
DROP DATABASE IF EXISTS db_calculos_enfermagem;
CREATE DATABASE db_calculos_enfermagem
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE db_calculos_enfermagem;
SET NAMES utf8mb4;


-- =========================================================
-- 1. USUÁRIO
-- =========================================================
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    curso VARCHAR(100),
    instituicao VARCHAR(100),
    data_cadastro DATE,
    nivel_atual ENUM('Iniciante', 'Intermediário', 'Avançado') DEFAULT 'Iniciante'
);


-- =========================================================
-- 2. AVALIAÇÃO INICIAL
-- =========================================================
CREATE TABLE avaliacao_inicial (
    id_avaliacao INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    data_realizacao DATE,
    nivel_diagnostico ENUM('Iniciante', 'Intermediário', 'Avançado'),
    observacoes TEXT,

    CONSTRAINT fk_avaliacao_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);


-- =========================================================
-- 3. RESULTADO DO DIAGNÓSTICO
-- =========================================================
CREATE TABLE resultado_diagnostico (
    id_resultado INT AUTO_INCREMENT PRIMARY KEY,
    id_avaliacao INT NOT NULL UNIQUE,

    operacao_adicao DECIMAL(5,2),
    operacao_subtracao DECIMAL(5,2),
    operacao_multiplicacao DECIMAL(5,2),
    operacao_divisao DECIMAL(5,2),

    nivel_sugerido ENUM('Iniciante', 'Intermediário', 'Avançado'),
    principais_dificuldades TEXT,

    CONSTRAINT fk_resultado_avaliacao
        FOREIGN KEY (id_avaliacao)
        REFERENCES avaliacao_inicial(id_avaliacao)
        ON DELETE CASCADE
);


-- =========================================================
-- 4. CONTEÚDO
-- =========================================================
CREATE TABLE conteudo (
    id_conteudo INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('Aula', 'Vídeo', 'Artigo') NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    nivel_dificuldade ENUM('Iniciante', 'Intermediário', 'Avançado')
);


-- =========================================================
-- 5. CONTEÚDO RECOMENDADO
-- =========================================================
CREATE TABLE conteudo_recomendado (
    id_conteudo_recomendado INT AUTO_INCREMENT PRIMARY KEY,
    id_resultado INT NOT NULL,
    id_conteudo INT NOT NULL,
    data_recomendacao DATE,

    CONSTRAINT fk_recomendado_resultado
        FOREIGN KEY (id_resultado)
        REFERENCES resultado_diagnostico(id_resultado)
        ON DELETE CASCADE,

    CONSTRAINT fk_recomendado_conteudo
        FOREIGN KEY (id_conteudo)
        REFERENCES conteudo(id_conteudo)
        ON DELETE CASCADE,

    CONSTRAINT uk_resultado_conteudo
        UNIQUE (id_resultado, id_conteudo)
);


-- =========================================================
-- 6. QUESTÃO
-- =========================================================
CREATE TABLE questao (
    id_questao INT AUTO_INCREMENT PRIMARY KEY,
    id_conteudo INT NOT NULL,
    enunciado TEXT NOT NULL,
    tipo_operacao ENUM('Adição', 'Subtração', 'Multiplicação', 'Divisão', 'Conversão', 'Dosagem', 'Regra de Três', 'Gotejamento', 'Decimais') NOT NULL,
    dificuldade ENUM('Fácil', 'Médio', 'Difícil', 'Avançado'),
    resposta_correta DECIMAL(10,2),
    explicacao TEXT,

    CONSTRAINT fk_questao_conteudo
        FOREIGN KEY (id_conteudo)
        REFERENCES conteudo(id_conteudo)
        ON DELETE CASCADE
);


-- =========================================================
-- 7. RESPOSTA DO USUÁRIO
-- =========================================================
CREATE TABLE resposta_usuario (
    id_resposta INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_questao INT NOT NULL,

    resposta_informada DECIMAL(10,2),
    status ENUM('Correta', 'Incorreta', 'Parcial') NOT NULL,
    tentativa INT DEFAULT 1,
    data_resposta DATETIME,

    CONSTRAINT fk_resposta_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_resposta_questao
        FOREIGN KEY (id_questao)
        REFERENCES questao(id_questao)
        ON DELETE CASCADE
);


-- =========================================================
-- 8. PRÁTICA DO DIA
-- =========================================================
CREATE TABLE pratica_do_dia (
    id_pratica INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    data_dia DATE,
    quantidade_blocos INT,
    status ENUM('Em andamento', 'Concluída', 'Cancelada') DEFAULT 'Em andamento',

    CONSTRAINT fk_pratica_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);


-- =========================================================
-- 9. PRÁTICA - QUESTÃO
-- =========================================================
CREATE TABLE pratica_questao (
    id_pratica INT NOT NULL,
    id_questao INT NOT NULL,

    PRIMARY KEY (id_pratica, id_questao),

    CONSTRAINT fk_pq_pratica
        FOREIGN KEY (id_pratica)
        REFERENCES pratica_do_dia(id_pratica)
        ON DELETE CASCADE,

    CONSTRAINT fk_pq_questao
        FOREIGN KEY (id_questao)
        REFERENCES questao(id_questao)
        ON DELETE CASCADE
);


-- =========================================================
-- 10. DESEMPENHO
-- =========================================================
CREATE TABLE desempenho (
    id_desempenho INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,

    percentual_acertos DECIMAL(5,2) DEFAULT 0.00,
    percentual_erros DECIMAL(5,2) DEFAULT 0.00,
    tempo_medio DECIMAL(10,2) DEFAULT 0.00,
    conteudos_concluidos INT DEFAULT 0,
    data_atualizacao DATE,

    CONSTRAINT fk_desempenho_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);


-- =========================================================
-- 11. CÁLCULO DE MEDICAMENTO
-- =========================================================
CREATE TABLE calculo_medicamento (
    id_calculo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,

    prescricao VARCHAR(255),
    disponivel VARCHAR(255),
    unidade VARCHAR(20),
    resultado_esperado DECIMAL(10,2),
    data_calculo DATETIME,

    CONSTRAINT fk_calculo_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);


-- =========================================================
-- 12. RESULTADO DO CÁLCULO
-- =========================================================
CREATE TABLE resultado_calculo (
    id_resultado INT AUTO_INCREMENT PRIMARY KEY,
    id_calculo INT NOT NULL,
    id_desempenho INT NOT NULL,

    resultado_usuario DECIMAL(10,2),
    resultado_correto DECIMAL(10,2),
    erro DECIMAL(10,2),
    tentativa INT DEFAULT 1,

    resolucao_passo_a_passo TEXT,
    explicacao_erro TEXT,

    CONSTRAINT fk_resultado_calculo
        FOREIGN KEY (id_calculo)
        REFERENCES calculo_medicamento(id_calculo)
        ON DELETE CASCADE,

    CONSTRAINT fk_resultado_desempenho
        FOREIGN KEY (id_desempenho)
        REFERENCES desempenho(id_desempenho)
        ON DELETE CASCADE
);


-- =========================================================
-- 13. MEDALHA
-- =========================================================
CREATE TABLE medalha (
    id_medalha INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    imagem VARCHAR(255)
);


-- =========================================================
-- 14. DESEMPENHO - MEDALHA
-- =========================================================
CREATE TABLE desempenho_medalha (
    id_desempenho INT NOT NULL,
    id_medalha INT NOT NULL,
    data_conquista DATE,

    PRIMARY KEY (id_desempenho, id_medalha),

    CONSTRAINT fk_dm_desempenho
        FOREIGN KEY (id_desempenho)
        REFERENCES desempenho(id_desempenho)
        ON DELETE CASCADE,

    CONSTRAINT fk_dm_medalha
        FOREIGN KEY (id_medalha)
        REFERENCES medalha(id_medalha)
        ON DELETE CASCADE
);


-- =========================================================
-- INSERTS (DADOS DE EXEMPLO)
-- =========================================================

-- USUÁRIOS
INSERT INTO usuario (nome, email, senha, curso, instituicao, data_cadastro, nivel_atual) VALUES
('Ana Souza', 'ana.souza@email.com', 'senha123', 'Enfermagem', 'Universidade São Paulo', '2026-08-01', 'Iniciante'),
('Bruno Oliveira', 'bruno.oliveira@email.com', 'senha123', 'Enfermagem', 'Universidade Paulista', '2026-08-03', 'Intermediário'),
('Camila Santos', 'camila.santos@email.com', 'senha123', 'Enfermagem', 'Centro Universitário São Camilo', '2026-08-05', 'Avançado'),
('Daniel Lima', 'daniel.lima@email.com', 'senha123', 'Enfermagem', 'Universidade Nove de Julho', '2026-08-10', 'Iniciante'),
('Eduarda Costa', 'eduarda.costa@email.com', 'senha123', 'Enfermagem', 'Universidade Anhembi Morumbi', '2026-08-12', 'Intermediário');

-- AVALIAÇÃO INICIAL
INSERT INTO avaliacao_inicial (id_usuario, data_realizacao, nivel_diagnostico, observacoes) VALUES
(1, '2026-08-02', 'Iniciante', 'Dificuldade em divisão e cálculos com decimais.'),
(2, '2026-08-04', 'Intermediário', 'Bom domínio das operações básicas, mas apresenta dificuldade em divisão.'),
(3, '2026-08-06', 'Avançado', 'Bom desempenho geral nas operações.'),
(4, '2026-08-11', 'Iniciante', 'Necessita reforço nas operações matemáticas básicas.'),
(5, '2026-08-13', 'Intermediário', 'Bom desempenho em adição e multiplicação, mas apresenta dificuldade em divisão e conversão.');

-- RESULTADO DO DIAGNÓSTICO
INSERT INTO resultado_diagnostico (id_avaliacao, operacao_adicao, operacao_subtracao, operacao_multiplicacao, operacao_divisao, nivel_sugerido, principais_dificuldades) VALUES
(1, 90.00, 80.00, 70.00, 50.00, 'Iniciante', 'Divisão e cálculos com números decimais.'),
(2, 95.00, 90.00, 85.00, 70.00, 'Intermediário', 'Divisão e cálculos de dosagem.'),
(3, 100.00, 95.00, 95.00, 90.00, 'Avançado', 'Pequenas dificuldades em cálculos com decimais.'),
(4, 70.00, 65.00, 60.00, 45.00, 'Iniciante', 'Operações básicas e divisão.'),
(5, 95.00, 90.00, 90.00, 75.00, 'Intermediário', 'Conversão de unidades e divisão.');

-- CONTEÚDOS
INSERT INTO conteudo (tipo, titulo, descricao, nivel_dificuldade) VALUES
('Aula', 'Adição na Enfermagem', 'Operações de adição aplicadas aos cálculos de enfermagem.', 'Iniciante'),
('Aula', 'Subtração na Enfermagem', 'Operações de subtração aplicadas aos cálculos de enfermagem.', 'Iniciante'),
('Aula', 'Multiplicação na Enfermagem', 'Aplicação da multiplicação nos cálculos de enfermagem.', 'Iniciante'),
('Aula', 'Divisão na Enfermagem', 'Aplicação da divisão nos cálculos de enfermagem.', 'Iniciante'),
('Aula', 'Conversão de Unidades', 'Conversão entre mg, g, mL e outras unidades.', 'Intermediário'),
('Aula', 'Cálculo de Dosagem', 'Cálculos de dosagem de medicamentos.', 'Intermediário'),
('Aula', 'Regra de Três', 'Aplicação da regra de três em cálculos de medicamentos.', 'Intermediário'),
('Aula', 'Cálculo de Gotejamento', 'Cálculos de gotejamento de soluções.', 'Avançado'),
('Aula', 'Cálculos com Decimais', 'Operações envolvendo números decimais.', 'Avançado'),
('Vídeo', 'Revisão de Cálculos de Medicamentos', 'Revisão dos principais cálculos de medicamentos.', 'Avançado');

-- RECOMENDAÇÕES
INSERT INTO conteudo_recomendado (id_resultado, id_conteudo, data_recomendacao) VALUES
(1, 4, '2026-08-02'), (1, 9, '2026-08-02'), (1, 5, '2026-08-02'),
(2, 4, '2026-08-04'), (2, 6, '2026-08-04'), (2, 7, '2026-08-04'),
(3, 8, '2026-08-06'), (3, 9, '2026-08-06'), (3, 10, '2026-08-06'),
(4, 4, '2026-08-11'), (4, 1, '2026-08-11'), (4, 2, '2026-08-11'), (4, 3, '2026-08-11'),
(5, 5, '2026-08-13'), (5, 4, '2026-08-13'), (5, 7, '2026-08-13');

-- QUESTÕES
INSERT INTO questao (id_conteudo, enunciado, tipo_operacao, dificuldade, resposta_correta, explicacao) VALUES
(1, 'Um paciente recebeu 250 mL de soro pela manhã e 150 mL à tarde. Qual foi o volume total?', 'Adição', 'Fácil', 400.00, '250 + 150 = 400 mL.'),
(2, 'Um frasco possui 500 mL. Após administrar 200 mL, quantos mL restaram?', 'Subtração', 'Fácil', 300.00, '500 - 200 = 300 mL.'),
(3, 'Um paciente recebe 2 comprimidos por dose durante 3 doses. Quantos comprimidos serão administrados?', 'Multiplicação', 'Fácil', 6.00, '2 × 3 = 6 comprimidos.'),
(4, 'Uma solução de 500 mL será dividida igualmente entre 5 recipientes. Quantos mL ficarão em cada um?', 'Divisão', 'Fácil', 100.00, '500 ÷ 5 = 100 mL.'),
(5, 'Quantos miligramas existem em 2 gramas?', 'Conversão', 'Médio', 2000.00, '2 × 1000 = 2000 mg.'),
(6, 'Um medicamento possui 500 mg em 10 mL. Quantos mL correspondem a 250 mg?', 'Dosagem', 'Médio', 5.00, '250 mg é metade de 500 mg, portanto são necessários 5 mL.'),
(7, 'Se 5 mL de uma solução contêm 100 mg, quantos mg existem em 10 mL?', 'Regra de Três', 'Médio', 200.00, '10 mL correspondem a 200 mg.'),
(8, 'Uma solução de 500 mL deve ser administrada em 5 horas utilizando equipo de 20 gotas/mL. Qual o fluxo aproximado?', 'Gotejamento', 'Difícil', 33.33, '500 × 20 ÷ 300 = 33,33 gotas/min.'),
(9, 'Um medicamento possui 2,5 mL e outro possui 1,75 mL. Qual é o volume total?', 'Decimais', 'Difícil', 4.25, '2,5 + 1,75 = 4,25 mL.'),
(10, 'Uma solução possui 1000 mL e será administrada em 10 horas. Qual o volume por hora?', 'Divisão', 'Avançado', 100.00, '1000 ÷ 10 = 100 mL/hora.');

-- PRÁTICAS
INSERT INTO pratica_do_dia (id_usuario, data_dia, quantidade_blocos, status) VALUES
(1, '2026-08-15', 3, 'Concluída'),
(2, '2026-08-15', 4, 'Concluída'),
(3, '2026-08-15', 5, 'Concluída'),
(4, '2026-08-15', 2, 'Em andamento'),
(5, '2026-08-15', 4, 'Concluída');

-- QUESTÕES DAS PRÁTICAS
INSERT INTO pratica_questao (id_pratica, id_questao) VALUES
(1, 4), (1, 5), (1, 9),
(2, 4), (2, 6), (2, 7),
(3, 8), (3, 9), (3, 10),
(4, 1), (4, 2), (4, 3),
(5, 4), (5, 5), (5, 7);

-- RESPOSTAS DOS USUÁRIOS
INSERT INTO resposta_usuario (id_usuario, id_questao, resposta_informada, status, data_resposta) VALUES
(1, 4, 100.00, 'Correta', '2026-08-15 08:30:00'),
(1, 5, 2000.00, 'Correta', '2026-08-15 08:32:00'),
(1, 9, 4.00, 'Incorreta', '2026-08-15 08:35:00'),
(2, 4, 100.00, 'Correta', '2026-08-15 09:00:00'),
(2, 6, 5.00, 'Correta', '2026-08-15 09:03:00'),
(2, 7, 150.00, 'Incorreta', '2026-08-15 09:05:00'),
(3, 8, 33.33, 'Correta', '2026-08-15 10:00:00'),
(3, 9, 4.25, 'Correta', '2026-08-15 10:03:00'),
(3, 10, 100.00, 'Correta', '2026-08-15 10:05:00'),
(4, 1, 400.00, 'Correta', '2026-08-15 11:00:00'),
(4, 2, 300.00, 'Correta', '2026-08-15 11:03:00'),
(4, 3, 8.00, 'Incorreta', '2026-08-15 11:06:00'),
(5, 4, 100.00, 'Correta', '2026-08-15 12:00:00'),
(5, 5, 2000.00, 'Correta', '2026-08-15 12:03:00'),
(5, 7, 150.00, 'Incorreta', '2026-08-15 12:06:00');

-- DESEMPENHO
INSERT INTO desempenho (id_usuario, percentual_acertos, percentual_erros, tempo_medio, conteudos_concluidos, data_atualizacao) VALUES
(1, 66.67, 33.33, 85.50, 4, '2026-08-16'),
(2, 66.67, 33.33, 72.30, 6, '2026-08-16'),
(3, 100.00, 0.00, 58.40, 9, '2026-08-16'),
(4, 66.67, 33.33, 105.20, 2, '2026-08-16'),
(5, 66.67, 33.33, 68.70, 7, '2026-08-16');

-- CÁLCULOS DE MEDICAMENTOS
INSERT INTO calculo_medicamento (id_usuario, prescricao, disponivel, unidade, resultado_esperado, data_calculo) VALUES
(1, 'Administrar 250 mg do medicamento', '500 mg em 10 mL', 'mL', 5.00, '2026-08-15 13:00:00'),
(2, 'Administrar 200 mg do medicamento', '100 mg em 5 mL', 'mL', 10.00, '2026-08-15 13:15:00'),
(3, 'Administrar 750 mg do medicamento', '500 mg em 10 mL', 'mL', 15.00, '2026-08-15 13:30:00'),
(4, 'Administrar 100 mg do medicamento', '200 mg em 10 mL', 'mL', 5.00, '2026-08-15 13:45:00'),
(5, 'Administrar 300 mg do medicamento', '150 mg em 5 mL', 'mL', 10.00, '2026-08-15 14:00:00');

-- RESULTADOS DOS CÁLCULOS
INSERT INTO resultado_calculo (id_calculo, id_desempenho, resultado_usuario, resultado_correto, erro, resolucao_passo_a_passo, explicacao_erro) VALUES
(1, 1, 5.00, 5.00, 0.00, '500 mg = 10 mL\n250 mg = X\nX = 250 × 10 ÷ 500\nX = 5 mL', 'Resposta correta.'),
(2, 2, 8.00, 10.00, 2.00, '100 mg = 5 mL\n200 mg = X\nX = 200 × 5 ÷ 100\nX = 10 mL', 'O resultado correto é 10 mL.'),
(3, 3, 15.00, 15.00, 0.00, '500 mg = 10 mL\n750 mg = X\nX = 750 × 10 ÷ 500\nX = 15 mL', 'Resposta correta.'),
(4, 4, 4.00, 5.00, 1.00, '200 mg = 10 mL\n100 mg = X\nX = 100 × 10 ÷ 200\nX = 5 mL', 'O resultado correto é 5 mL.'),
(5, 5, 10.00, 10.00, 0.00, '150 mg = 5 mL\n300 mg = X\nX = 300 × 5 ÷ 150\nX = 10 mL', 'Resposta correta.');

-- MEDALHAS
INSERT INTO medalha (nome, descricao, imagem) VALUES
('Primeiro Passo', 'Concluiu a primeira prática.', 'primeiro_passo.png'),
('Mestre da Adição', 'Bom desempenho em questões de adição.', 'mestre_adicao.png'),
('Mestre da Divisão', 'Bom desempenho em questões de divisão.', 'mestre_divisao.png'),
('Calculista', 'Concluiu atividades de cálculos de medicamentos.', 'calculista.png'),
('Destaque da Semana', 'Manteve bom desempenho durante a semana.', 'destaque_semana.png'),
('Especialista em Dosagem', 'Concluiu atividades de cálculo de dosagem.', 'especialista_dosagem.png');

-- MEDALHAS CONQUISTADAS
INSERT INTO desempenho_medalha (id_desempenho, id_medalha, data_conquista) VALUES
(1, 1, '2026-08-15'), (1, 2, '2026-08-16'),
(2, 1, '2026-08-15'), (2, 4, '2026-08-16'),
(3, 1, '2026-08-15'), (3, 3, '2026-08-15'), (3, 4, '2026-08-16'), (3, 5, '2026-08-16'), (3, 6, '2026-08-16'),
(5, 1, '2026-08-15'), (5, 4, '2026-08-16'), (5, 6, '2026-08-16');
