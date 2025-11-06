#install.packages('ComplexHeatmap')
#install.packages('circlize')
#install.packages('grid')

library(ComplexHeatmap)
library(circlize)
library(grid)

# --- load CSV ---
csv_path <- "/Users/yashp/Desktop/DSC180A Capstone Project Q1/DSC180ATeam2Github/25fa-dsc180a-team2/jupyternotebooks/KateJupyterNotebooks/fig1b.csv"
prev_df  <- read.csv(csv_path, check.names = FALSE, stringsAsFactors = FALSE)
if (names(prev_df)[1] == "" || is.na(names(prev_df)[1])) names(prev_df)[1] <- "disease"

age_cols <- c("16-24","25-44","45-64","65-84",">85")
stopifnot(all(age_cols %in% names(prev_df)))

# matrix (already %)
m <- as.matrix(prev_df[, age_cols, drop = FALSE])
rownames(m) <- make.unique(prev_df$disease)
colnames(m) <- age_cols
m[is.na(m)] <- 0

# --- manual clusters (CSV snake_case) ---
g3 <- c("other_neurological","coagulopathy","depression","liver_disease","alcohol_abuse","drug_abuse")           # TOP
g2 <- c("deficiency_anemias","paralysis","weight_loss","rheumatoid_arthritis","solid_tumor","lymphoma",
        "peptic_ulcer","blood_loss_anemia","psychoses","aids","metastatic_cancer","diabetes_complicated","obesity")  # MIDDLE
g1 <- c("renal_failure","valvular_disease","hypothyroidism","peripheral_vascular","pulmonary_circulation",
        "chronic_pulmonary","diabetes_uncomplicated","congestive_heart_failure","fluid_electrolyte",
        "hypertension","cardiac_arrhythmias")                                                                          # BOTTOM

order_from <- function(keys, all) { idx <- match(tolower(keys), tolower(all)); idx[!is.na(idx)] }
row_order <- c(order_from(g3, rownames(m)), order_from(g2, rownames(m)), order_from(g1, rownames(m)))
m_ord <- m[row_order, , drop = FALSE]

# split factor in the required order: TOP=3, MIDDLE=2, BOTTOM=1  (as in the paper image)
cl_ord <- factor(c(rep("3", length(g3)), rep("2", length(g2)), rep("1", length(g1))),
                 levels = c("3","2","1"))

# robust pretty labels (no c("…","…") printing)
pretty_labels <- function(x) {
  vapply(strsplit(gsub("_"," ", x), " +"), function(words) {
    paste(vapply(words, function(w)
      paste0(toupper(substring(w, 1, 1)), tolower(substring(w, 2))), character(1)), collapse = " ")
  }, character(1))
}
row_lab <- pretty_labels(rownames(m_ord))

# color scale like the paper
col_fun <- colorRamp2(c(0, 25, 50, 60, 80),
                      c("#0d0d0d", "#ffff66", "#ffb000", "#EB4A27", "#FF0000"))

# column dendrogram but KEEP age order
desired_cols <- c("16-24","25-44","45-64","65-84",">85")
m_ord <- m_ord[, desired_cols, drop = FALSE]
hc_col <- hclust(dist(t(m_ord)), method = "average")

ht <- Heatmap(
  m_ord,
  name = "Prevalence (%)",
  col = col_fun,
  
  # rows: your fixed blocks (3 top, 2 mid, 1 bottom) + dendrograms **within** each slice
  row_split = cl_ord,
  cluster_rows = TRUE,
  cluster_row_slices = TRUE,      # draw small trees per block
  row_gap = unit(0.6, "mm"),
  show_row_dend = TRUE,
  show_row_names = TRUE,
  row_labels = row_lab,
  row_names_gp = gpar(fontsize = 8),
  
  # columns: show dendrogram but do NOT reorder ages
  cluster_columns = as.dendrogram(hc_col),
  column_order = desired_cols,
  show_column_dend = TRUE,
  column_names_rot = 90,
  
  column_title = "Age Bracket",
  heatmap_legend_param = list(title = "Prevalence (%)"),
  
  # slice titles on the left exactly as in the paper (3 at top, then 2, then 1)
  row_title = c("1","3","2"),
  row_title_rot = 0,
  row_title_side = "left",
  row_title_gp = gpar(fontsize = 11, fontface = "bold")
)

draw(ht)

output_path <- file.path('/Users/yashp/Desktop/DSC180A Capstone Project Q1/DSC180ATeam2Github/25fa-dsc180a-team2/jupyternotebooks/YashJupyterNotebookAssets', "fig1b.png") 
png(filename = output_path, width = 8, height = 6, units = "in", res = 300)
draw(ht, newpage = TRUE)
dev.off()

cat("✅ Saved heatmap to:", output_path, "\n")
