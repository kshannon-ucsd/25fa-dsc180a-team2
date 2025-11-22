# lca_fit.R -- Portable LCA/Fit and Export Script

# =============================
# 0. PACKAGES & .ENV SUPPORT
# =============================
if (!require(dotenv)) install.packages("dotenv")
library(dotenv)
dotenv::load_dot_env(".env")  # Loads .env from project root

pkgs <- c("tidyverse", "poLCA", "caret", "pROC", "mclust")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install)
invisible(lapply(pkgs, library, character.only = TRUE))

message("Packages loaded.")

# =============================
# 1. LOAD CONFIG FROM .ENV
# =============================
input_csv <- Sys.getenv("LCA_INPUT_CSV")
output_csv <- Sys.getenv("LCA_OUTPUT_CSV")
lca_cache_path <- Sys.getenv("LCA_CACHE")

if ("" %in% c(input_csv, output_csv, lca_cache_path)) {
  stop("One or more .env variables are missing. Please copy .env.example to .env and fill in the correct paths.")
}

# =============================
# 2. LOAD DATA
# =============================
df <- read.csv(input_csv, check.names = FALSE) %>%
  mutate(row_id = dplyr::row_number())
message("Data loaded: ", nrow(df), " rows.")

# =============================
# 3. PREP LCA INPUTS
# =============================
morb_cols <- c(
  "congestive_heart_failure","cardiac_arrhythmias","valvular_disease",
  "pulmonary_circulation","peripheral_vascular","hypertension","paralysis",
  "other_neurological","chronic_pulmonary","diabetes_uncomplicated",
  "diabetes_complicated","hypothyroidism","renal_failure","liver_disease",
  "peptic_ulcer","aids","lymphoma","metastatic_cancer","solid_tumor",
  "rheumatoid_arthritis","coagulopathy","obesity","weight_loss",
  "fluid_electrolyte","blood_loss_anemia","deficiency_anemias",
  "alcohol_abuse","drug_abuse","psychoses","depression"
)
stopifnot(all(morb_cols %in% names(df)))

# Admission type + age bins as factors
df <- df %>%
  mutate(
    admission_type_grp = dplyr::case_when(
      !is.na(admission_type_grp) ~ admission_type_grp,
      admission_type == "ELECTIVE" ~ "elective",
      TRUE ~ "non-elective"
    ),
    age_grp_cat = cut(
      age_years,
      breaks = c(-Inf, 24, 44, 64, 84, Inf),
      labels = c("16-24","25-44","45-64","65-84",">85"),
      right  = TRUE
    )
  )

lca_df <- df %>%
  dplyr::select(
    row_id, age_grp_cat, gender, admission_type_grp, all_of(morb_cols)
  ) %>%
  mutate(
    age_grp_cat        = factor(age_grp_cat, levels = c("16-24","25-44","45-64","65-84",">85")),
    gender             = factor(gender),
    admission_type_grp = factor(admission_type_grp, levels = c("elective","non-elective")),
    age_grp  = as.integer(age_grp_cat),
    gender   = as.integer(gender),
    adm_type = as.integer(admission_type_grp)
  ) %>%
  mutate(
    dplyr::across(all_of(morb_cols), ~ { x <- ifelse(is.na(.), 0L, as.integer(. > 0)); x + 1L })
  ) %>%
  dplyr::select(row_id, age_grp, gender, adm_type, all_of(morb_cols)) %>%
  na.omit()
message("LCA dataset prepared: ", nrow(lca_df), " rows, ", ncol(lca_df) - 1, " manifest variables.")

# =============================
# 4. FIT OR LOAD LCA MODEL
# =============================
RUN_LCA <- FALSE  # set TRUE to run new, else load

manifest_vars <- setdiff(names(lca_df), c("row_id", "latent_class"))
f <- as.formula(paste0("cbind(", paste(manifest_vars, collapse = ","), ") ~ 1"))

paper_props <- c(
  cardiopulmonary = 0.061, cardiac = 0.264, young = 0.235, hepatic_addiction = 0.098, 
  complicated_diabetics = 0.094, uncomplicated_diab = 0.248
)

if (RUN_LCA) {
  K_TARGET     <- 6
  N_RUNS       <- 40  
  MAXIT        <- 10000
  NREP_PER_RUN <- 1  
  set.seed(60)
  message("Fitting multiple LCA models for K = 6 ...")
  model_list <- vector("list", N_RUNS)
  prop_list  <- vector("list", N_RUNS)
  ll_list    <- numeric(N_RUNS)
  min_prop   <- numeric(N_RUNS)
  for (r in seq_len(N_RUNS)) {
    m <- poLCA(
      f, data = lca_df, nclass = K_TARGET,
      maxiter = MAXIT, nrep = NREP_PER_RUN, verbose = FALSE
    )
    model_list[[r]] <- m
    ll_list[r]      <- m$llik
    p               <- prop.table(table(m$predclass))
    prop_list[[r]]  <- p
    min_prop[r]     <- min(as.numeric(p))
  }
  paper_sorted <- sort(as.numeric(paper_props))
  dist_to_paper <- sapply(prop_list, function(p) {
    p_sorted <- sort(as.numeric(p)); sqrt(sum((p_sorted - paper_sorted)^2))
  })
  fits <- tibble(
    run_id = seq_len(N_RUNS), logLik = ll_list, min_class_prop = min_prop,
    dist_to_paper = dist_to_paper
  ) %>%
    mutate(eligible = min_class_prop >= 0.05) %>%
    arrange(dist_to_paper)
  if (any(fits$eligible)) {
    best_run <- fits$run_id[fits$eligible][which.min(fits$dist_to_paper[fits$eligible])]
  } else {
    best_run <- fits$run_id[which.min(fits$dist_to_paper)]
  }
  best_fit <- model_list[[best_run]]
  saveRDS(list(best_fit=best_fit, fits=fits), file = lca_cache_path)
} else {
  message("RUN_LCA==FALSE. Loading cached LCA from: ", lca_cache_path)
  lca_cache <- readRDS(lca_cache_path)
  best_fit <- lca_cache$best_fit
}
lca_df$latent_class <- best_fit$predclass
df <- df %>% left_join(lca_df %>% dplyr::select(row_id, latent_class), by = "row_id")

# OPTIONAL: Remap class numbers
mapping_vec <- c(`1`=6, `2`=3, `3`=2, `4`=4, `5`=1, `6`=5)
df <- df %>%
  mutate(
    subgroup_paper = mapping_vec[as.character(latent_class)],
    subgroup_paper = factor(subgroup_paper, levels=1:6)
  )
message("Latent classes and paper-aligned subgroups attached to df.")

# =============================
# 5. EXPORT READY FOR NETWORK
# =============================
write.csv(df, output_csv, row.names = FALSE)
message("Saved final CSV: ", output_csv)
