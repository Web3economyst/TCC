# ============================================================
# run_all.R — roda o projeto inteiro, do dado bruto às tabelas
#
# COMO USAR
#   1. Abra a pasta do projeto no RStudio (a que tem o arquivo
#      vazio ".here", este run_all.R e a pasta R/).
#   2. No console: source("run_all.R")
#   3. No fim, as tabelas e figuras do texto estão em
#      output/13_saida/texto/
#
# O que acontece:
#   - Cada script roda numa área própria, na ordem abaixo, e grava
#     as suas saídas em output/<número>_saida/.
#   - Se um script der erro, o run_all para ali e diz qual foi, para
#     você não seguir com resultados pela metade.
#   - Os gráficos não abrem na tela durante o run_all (fica mais
#     rápido). Para vê-los, rode o script sozinho ou mude a opção
#     tcc.mostrar_graficos abaixo para TRUE.
#
# Tempo: uns 10 a 15 minutos com os dados já baixados. Na primeira
# vez, o 01_import.R baixa os dados financeiros (internet), e pode
# levar bem mais.
# ============================================================

# ------------------------------------------------------------
# Escolhas
# ------------------------------------------------------------

# TRUE: roda também as análises complementares, que não estão no
# texto (DI, VAR, estudo de eventos das pesquisas etc.). Elas não
# mudam nenhum resultado do texto.
RODAR_COMPLEMENTARES <- FALSE

options(tcc.mostrar_graficos = FALSE)

# ------------------------------------------------------------
# Ordem dos scripts
# ------------------------------------------------------------

principais <- c(
  "01_import.R",              # lê os dados (baixa só o que faltar)
  "02_cleaning.R",            # uma linha por pregão em cada ciclo
  "03_variables.R",           # variações diárias e dummies
  "03b_validacao_critica.R",  # para tudo se a base tiver problema
  "04_descriptive.R",         # Tabela 1 (descritivas)
  "05_stationarity.R",        # ADF, PP e KPSS (citados na 4.1)
  "06_models.R",              # modelos E, E1 e D (Tabelas 2, 3 e 4)
  "06b_magnitude.R",          # ganho de R² e decomposição de Shapley
  "07_diagnostics.R",         # resíduos, Ljung-Box, DFBETAS (Tabela 5, Apêndice D)
  "08_ccf_granger.R",         # correlação cruzada e Granger (4.4.2, Apêndice C)
  "09_ardl.R",                # escolha das defasagens pelo BIC (4.4.1)
  "09b_comparacao_ciclos.R",  # β por ciclo e teste de igualdade (Tabela 3)
  "09c_noites_eleitorais.R",  # noites eleitorais: previsto x observado (4.5)
  "09d_interacao_eventos.R",  # identifica os pregões pós-1º turno (usado pelo 09e)
  "09e_dummy_choque.R",       # modelo E + dummy (Tabela 2)
  "10_robustness.R",          # robustezes R0 a R14 (Tabela 6)
  "10e_favorito_azarao.R",    # correção do viés favorito-azarão (Tabela 6)
  "13_tables_figures.R"       # monta as tabelas e figuras do texto
)

complementares <- c(
  "04b_probabilidade_pesquisas.R",  # conferência da série das pesquisas
  "04c_controles_adicionais.R",     # DXY, Brent, Selic (baixa dados na 1ª vez)
  "10b_di1_dinamica.R",             # DI de 1 ano
  "10f_defasagem_pesquisas.R",      # pesquisas com 0, 1 e 2 dias de defasagem
  "11_var.R",                       # VAR por ciclo
  "12_event_study.R",               # estudo de eventos das pesquisas
  "12b_teste_h4.R",                 # surpresa das pesquisas x preços
  "99_auditoria.R"                  # relatório de conferência da base
)

# O 10b é só do DI: roda apenas com INCLUIR_DI = TRUE no 00_config.R
cfg <- new.env(); sys.source(file.path("R", "00_config.R"), envir = cfg)
if (!isTRUE(cfg$INCLUIR_DI)) complementares <- setdiff(complementares, "10b_di1_dinamica.R")

# Os complementares rodam antes do 13, para entrarem no material
# complementar que ele monta.
ordem <- if (RODAR_COMPLEMENTARES) c(head(principais, -1), complementares, "13_tables_figures.R") else principais

# ------------------------------------------------------------
# Execução
# ------------------------------------------------------------

if (!file.exists(".here"))
  stop("Abra o projeto pela pasta que tem o arquivo '.here' (Session > Set Working Directory).", call. = FALSE)

faltando <- ordem[!file.exists(file.path("R", ordem))]
if (length(faltando))
  stop("Scripts não encontrados na pasta R/: ", paste(faltando, collapse = ", "), call. = FALSE)

inicio <- Sys.time()
tempos <- numeric(0)

for (s in ordem) {
  message("\n==================== ", s, " ====================")
  t0 <- Sys.time()
  tryCatch(
    source(file.path("R", s), local = new.env(), encoding = "UTF-8"),
    error = function(e) stop("\n\nO run_all parou no ", s, ":\n  ", conditionMessage(e),
                             "\nCorrija esse script e rode o run_all de novo.", call. = FALSE)
  )
  tempos[s] <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  message("(", s, ": ", round(tempos[s]), " s)")
}

message("\n============================================================")
message("Tudo pronto em ", round(as.numeric(difftime(Sys.time(), inicio, units = "mins")), 1), " minutos.")
message("Tabelas e figuras do texto:  output/13_saida/texto/")
message("Material complementar:       output/13_saida/complementares/")
message("============================================================")

# Versões do R e dos pacotes usados nesta rodada
dir.create("output", showWarnings = FALSE)
writeLines(capture.output(sessionInfo()), file.path("output", "sessionInfo.txt"))
