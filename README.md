# Quanto as expectativas eleitorais movem o mercado financeiro brasileiro?

Códigos do Trabalho de Conclusão de Curso de **Gabriel Follmer de Mattos** (Ciências Econômicas, UFRGS, 2026/2), orientado pelo Prof. Dr. Fernando Augusto Boeira Sabino da Silva.

O trabalho mede quanto o Ibovespa e o dólar se movem quando muda a probabilidade de vitória do candidato do PT nas eleições presidenciais de 2018, 2022 e 2026. A probabilidade vem dos mercados de previsão (Betfair em 2018 e 2022, Polymarket em 2026) e, como comparação, de um agregador de pesquisas eleitorais. Tudo é medido no fechamento de cada pregão da B3.

Este guia explica como rodar tudo, onde está cada tabela e figura do texto e o que fazer se algo der errado. Não é preciso saber R a fundo: basta seguir os passos.
Pasta dados: https://drive.google.com/file/d/1LuM6YBeLi3-m3PMBAbpx9fnwC-SV8jm1/view?usp=sharing (É necessário os dados extraídos para rodar os códigos)

---

## 1. Antes de começar

Você vai precisar de:

- **R** (o texto usou a versão 4.6.0) e, de preferência, o **RStudio**.
- **Internet só na primeira vez**, se os dados financeiros ainda não estiverem em `data/raw/`. Os pacotes que faltarem são instalados sozinhos pelo `R/00_packages.R`.
- A pasta do projeto organizada assim:

```
TCC/
├── .here                  ← arquivo vazio; marca a raiz do projeto
├── run_all.R              ← roda tudo
├── README.md              ← este guia
├── R/                     ← os scripts, numerados na ordem em que rodam
├── data/
│   ├── raw/               ← dados brutos (financeiros .rds)
│   │   └── eleitoral/     ← Betfair, Polymarket e o painel das pesquisas
│   └── processed/         ← base pronta (criada pelos scripts)
└── output/                ← tudo o que os scripts produzem (criada sozinha)
```

Em `data/raw/eleitoral/` devem estar: `betfair_2018_diario.csv`, `betfair_2018_diario_fechamento_b3.csv`, `betfair_2022_diario.csv`, `betfair_2022_diario_fechamento_b3.csv`, `mercado_2026_diario.csv`, `polymarket_serie_horaria.csv`, `polymarket_mercados.csv` e `painel_diario.csv` (a probabilidade diária das pesquisas). Se eles estiverem numa pasta `pasta_dados/` ao lado do projeto, os scripts também os encontram.

---

## 2. Como rodar (3 passos)

1. **Abra a pasta do projeto no RStudio.** O mais fácil é abrir o `run_all.R` e usar *Session > Set Working Directory > To Source File Location*. A pasta certa é a que tem o arquivo `.here`.
2. **No console, digite:**
   ```r
   source("run_all.R")
   ```
3. **Espere.** Leva uns 10 a 15 minutos com os dados já baixados. O console mostra cada script começando e terminando, com o tempo de cada um.

Quando terminar, aparece "Tudo pronto". As tabelas e figuras do texto estarão em **`output/13_saida/texto/`**.

**Quer rodar um script só?** Pode, desde que os anteriores já tenham rodado pelo menos uma vez. Abra o script e clique em *Source*. Rodado sozinho, ele também mostra os gráficos no painel do RStudio.

**Quer as análises complementares também?** No começo do `run_all.R`, troque `RODAR_COMPLEMENTARES <- FALSE` por `TRUE`. Elas não mudam nenhum resultado do texto.

**E os juros futuros (DI)?** O texto analisa só o Ibovespa e o dólar, e o código segue a mesma escolha: em `R/00_config.R`, `INCLUIR_DI <- FALSE`. Trocando para `TRUE`, o DI de 1 e de 5 anos volta como exercício complementar em todos os modelos e tabelas, sem alterar nenhum resultado do Ibovespa e do dólar, porque cada ativo é estimado separadamente.

### Como conferir que deu certo

No console, ao fim do `06_models.R`, o modelo E da amostra empilhada deve mostrar **β = −0,112 para o Ibovespa (N = 711)** e **β = 0,088 para o dólar (N = 709)**. Se esses números baterem, a base foi montada como no texto.

---

## 3. Onde está cada tabela e figura do texto

Todas ficam em `output/13_saida/texto/`, em CSV (para abrir no Excel) e em LaTeX. Os nomes seguem a numeração do Word.

| No texto | Arquivo | Script que calcula |
|---|---|---|
| Tabela 1 – Estatísticas descritivas | `Tabela_1_Descritivas` | `04_descriptive.R` |
| Tabela 2 – Modelo principal e extensão com dummy | `Tabela_2_Modelo_principal` | `06_models.R`, `09e_dummy_choque.R` (inclui a decomposição de Shapley) |
| Tabela 3 – Empilhado, por ciclo e teste de igualdade | `Tabela_3_Ciclos` | `06_models.R`, `06b_magnitude.R`, `09b_comparacao_ciclos.R` |
| Tabela 4 – Modelos estático e dinâmicos | `Tabela_4_Estatico_dinamico` | `06_models.R` |
| Tabela 5 – Influência dos pregões pós-1º turno | `Tabela_5_Influencia_pregoes` | `07_diagnostics.R` |
| Tabela 6 – Principais testes de robustez | `Tabela_6_Robustez` | `10_robustness.R`, `10e_favorito_azarao.R` |
| Tabela C1 – Granger nos dois sentidos | `Tabela_C1_Granger` | `08_ccf_granger.R` |
| Figura D1 – Resíduos x ajustados, QQ-plot e histograma | `Figura_D1_Residuos_ajustados_QQ_histograma.png` | `07_diagnostics.R` |
| Figura D2 – Resíduos no tempo | `Figura_D2_Residuos_no_tempo.png` | `07_diagnostics.R` |
| Figuras D3 e D4 – FAC e FACP dos resíduos | `Figura_D3_FAC_FACP_Ibovespa.png`, `Figura_D4_FAC_FACP_Dolar.png` | `07_diagnostics.R` |
| Figuras D5 e D6 – Ljung-Box por defasagem | `Figura_D5_Ljung_Box_Ibovespa.png`, `Figura_D6_Ljung_Box_Dolar.png` | `07_diagnostics.R` |

Os números citados no texto sem tabela própria estão nas saídas de cada script:

| Resultado no texto | Onde está |
|---|---|
| Testes ADF, PP e KPSS (4.1) | `output/05_saida/stationarity_summary.csv` |
| Escolha da ordem (0, 0) pelo BIC (3.4.1 e 4.4.1) | `output/09_saida/ardl_bic_grid_all.csv` |
| Correlação cruzada e pré-branqueamento (4.4.2) | `output/08_saida/` (arquivos `ccf_*`) |
| Ljung-Box com 5 a 25 defasagens (Apêndice D) | `output/07_saida/diagnostics_ljung_box.csv` |
| Noites eleitorais: previsto x observado (4.5) | `output/09c_saida/noites_previsto_realizado.csv` |
| Efeito de 10 p.p. e de um desvio-padrão (4.2) | `output/06b_saida/magnitude.csv`, `output/10e_saida/favorito_azarao_dp_sd.csv` |

Tudo o que foi calculado mas não está no texto vai para `output/13_saida/complementares/`, com o prefixo `Extra_`.

---

## 4. O que cada script faz

Os scripts rodam na ordem dos números. Cada um grava o que produz na sua própria pasta, `output/<número>_saida/`.

### Preparação

| Script | O que faz |
|---|---|
| `00_config.R` | Todas as escolhas do trabalho num lugar só: datas de cada ciclo, candidatos, ativos analisados (com ou sem o DI), controles, defasagens máximas. **Se quiser mudar algo, é aqui.** |
| `00_paths.R`, `00_packages.R`, `00_functions.R` | Caminhos das pastas, pacotes e funções usadas por vários scripts (Newey-West, Granger, decomposição de Shapley etc.). |
| `01_import.R` | Lê os dados eleitorais e financeiros. Só baixa da internet o que ainda não estiver em `data/raw/`. |
| `02_cleaning.R` | Monta a base com uma linha por pregão da B3 em cada ciclo e alinha a probabilidade ao horário de fechamento. |
| `03_variables.R` | Cria as variações diárias e as indicadoras dos pregões eleitorais. |
| `03b_validacao_critica.R` | Confere a base e **para tudo** se houver datas repetidas, horários diferentes entre ciclos ou dados faltando demais. |

### Resultados do texto

| Script | O que faz |
|---|---|
| `04_descriptive.R` | Estatísticas descritivas (Tabela 1). |
| `05_stationarity.R` | Testes de raiz unitária e de estacionariedade (ADF, PP e KPSS). |
| `06_models.R` | Modelo principal (E) e as versões com uma defasagem (E1 e D), por MQO com erros-padrão de Newey-West. |
| `06b_magnitude.R` | Quanto a probabilidade explica: ganho de R², efeito de um desvio-padrão e decomposição de Shapley do R² em três grupos (probabilidade, controles internacionais e efeito de ciclo). |
| `07_diagnostics.R` | Diagnósticos dos resíduos (Apêndice D), influência de cada pregão (Tabela 5) e testes complementares. |
| `08_ccf_granger.R` | Correlação cruzada com pré-branqueamento e testes de Granger nos dois sentidos, com correção de Benjamini-Hochberg. |
| `09_ardl.R` | Confere, pelo BIC, que nenhuma defasagem adicional melhora o modelo. |
| `09b_comparacao_ciclos.R` | Estima o β em cada ciclo e testa se ele é igual nos três. |
| `09c_noites_eleitorais.R` | Compara a reação prevista pela sensibilidade da campanha com a observada nas noites eleitorais. É uma comparação descritiva, não um teste. |
| `09d_interacao_eventos.R` | Identifica e confere os primeiros pregões após cada 1º turno (o 09e depende dele). |
| `09e_dummy_choque.R` | Modelo E com a dummy desses pregões e a decomposição do R² da Tabela 2. |
| `10_robustness.R` | Exercícios de robustez: sem pregões eleitorais, probabilidade PT × rival, só campanha, pesquisas, probabilidade às 23h59 etc. |
| `10e_favorito_azarao.R` | Corrige a probabilidade pelo viés favorito-azarão (a = 1,64 e a = 2,72) e reestima o modelo E. |
| `13_tables_figures.R` | Não estima nada: junta as saídas acima e monta as tabelas e figuras do texto. |

### Complementares (fora do texto)

`04b` (conferência da série das pesquisas), `04c` (controles adicionais), `10b` (DI de 1 ano; só com `INCLUIR_DI <- TRUE`), `10f` (defasagem das pesquisas), `11` (VAR), `12` e `12b` (estudo de eventos das pesquisas) e `99` (relatório de conferência da base). Rodam só com `RODAR_COMPLEMENTARES <- TRUE`.

---

## 5. Escolhas que vale conhecer

- **Horário.** A probabilidade de cada dia é o último preço até o fechamento do pregão da B3 (17h com horário de verão nos EUA, 18h sem ele). O Ibovespa e os controles são de fechamento. O dólar é o preço de ajuste do dólar futuro, apurado entre 15h50 e 16h.
- **Variações, não níveis.** A pergunta é como os preços reagem a mudanças na expectativa, e informação nova move o preço no dia em que chega. Os testes de raiz unitária servem de conferência.
- **Mesma amostra em E, E1 e D.** O primeiro pregão de cada ciclo sai das três especificações, para que os resultados sejam comparáveis (N = 711 no Ibovespa e 709 no dólar).
- **Erros-padrão.** Newey-West calculados dentro de cada ciclo, sem tratar o fim de uma eleição e o começo da seguinte como dias consecutivos.
- **Pesquisas.** O agregador segue o método do orientador (regressão local linear com kernel de Epanechnikov, largura de banda por validação temporal e conversão da margem em probabilidade pela normal). Aqui ele é recalculado dia a dia, só com as pesquisas já disponíveis em cada data. A pesquisa com fim de campo no dia D entra a partir do pregão seguinte a D.
- **2018.** A janela principal começa em 11/09/2018, primeiro pregão em que a variação da probabilidade é toda do contrato de Haddad.

Janelas da estimação principal: 2018, de 11/09/2018 a 29/10/2018; 2022, de 11/03/2021 a 31/10/2022; 2026, de 18/09/2025 a 26/10/2026.

### Variáveis

| No código | O que é | Unidade |
|---|---|---|
| `p_pt` / `dp_pt` | Probabilidade de vitória do PT / variação diária | 0–1 / p.p. |
| `p_h2h` / `dp_h2h` | Probabilidade do PT contra o adversário final (robustez R3) | 0–1 / p.p. |
| `p_pesq` / `dp_pesq` | Probabilidade do PT pelo agregador de pesquisas | 0–1 / p.p. |
| `p_pt_fimdia` / `dp_pt_fimdia` | Probabilidade às 23h59 (robustez R7) | 0–1 / p.p. |
| `r_ibov` | Retorno do Ibovespa | % |
| `r_usd` | Variação do dólar futuro (preço de ajuste) | % |
| `r_spx`, `d_ust10`, `r_vix` | Controles: S&P 500, Treasury de 10 anos e VIX | %, p.b., % |
| `d_di1`, `d_di5` | Variação das taxas de 1 e 5 anos (só com `INCLUIR_DI <- TRUE`) | p.b. |

---

## 6. Se algo der errado

| Mensagem | O que fazer |
|---|---|
| "Abra o projeto pela pasta que tem o arquivo '.here'" | O R está na pasta errada. Use *Session > Set Working Directory* e escolha a pasta do projeto. |
| "O run_all parou no XX.R" | A mensagem logo abaixo diz o motivo. Corrija e rode o `run_all.R` de novo; não é preciso apagar nada. |
| "Falta output/09d_saida/eventos_verificacao.csv" | O 09e precisa do 09d. Rode o 09d antes (o `run_all` já faz isso na ordem certa). |
| "Figura do texto não encontrada" | O `07_diagnostics.R` não rodou até o fim. Rode-o e depois o `13_tables_figures.R`. |
| Arquivo da Betfair ou da Polymarket não encontrado | Confira se os CSVs estão em `data/raw/eleitoral/` (seção 1). |
| Pacote não instala | Instale à mão com `install.packages("nome")` e rode de novo. |
| Aviso de base SIMULADA | O `01_import.R` não conseguiu baixar os dados financeiros. Rode-o com internet. |

Ao fim de cada rodada, `output/sessionInfo.txt` registra as versões do R e dos pacotes usados.

---

## 7. Créditos

O método do agregador de pesquisas (kernel, critério de escolha da largura de banda e conversão da margem em probabilidade) foi desenvolvido pelo orientador, Prof. Dr. Fernando Augusto Boeira Sabino da Silva, em material metodológico ainda não publicado. Os dados de mercados de previsão vêm da Betfair Historical Data e da Polymarket; os financeiros, da B3 e do Yahoo Finance; os registros das pesquisas, do Portal de Dados Abertos do TSE.
