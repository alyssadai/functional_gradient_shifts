#!/usr/bin/env Rscript

# Description: Formats inputs for rogme. From component-labelled + z-scored gradient maps, extracts and saves values of each component's vertices in all gradient maps into a separate long-format file for rogme. NAN values are removed.
# Outputs: k component-specific .csv files each containing a column of gradient map labels (child, adolescent, adult) (gr) and a column of corresponding gradient values of all member vertices for the specified component (obs).
# Usage: ./rogme_input_preprocessing.R

suppressPackageStartupMessages({
  library(rogme)
  library(cowplot)
  library(ggplot2)
  library(data.table)
  library(tidyverse)
})

in_dir <- "gradient_maps_zscore" # directory containing zscored gradients
out_dir <- "shiftfn/inputs" # shiftfn inputs: component files with gradient values of all groups (i.e., gradients)
child_all_comps_norm_df <- read.csv(file.path(in_dir,"merged_LR_comp-labels_child-gradient2-INV-values_zscore_nomidline.txt"), sep=" ", header=F, col.names=c("component", "child_grd"))
adoles_all_comps_norm_df <- read.csv(file.path(in_dir,"merged_LR_comp-labels_adolesc-gradient1-values_zscore_nomidline.txt"), sep=" ", header=F, col.names=c("component", "adolescent_grd"))
adult_all_comps_norm_df <- read.csv(file.path(in_dir,"merged_LR_comp-labels_adult-gradient1-values_zscore_nomidline.txt"), sep=" ", header=F, col.names=c("component", "adult_grd"))

# concatenate maturational maps
matur_comps_norm_df <- cbind(child_all_comps_norm_df, adoles_all_comps_norm_df$adolescent_grd, adult_all_comps_norm_df$adult_grd)
colnames(matur_comps_norm_df) <- c("component", "child", "adolescent", "adult")

# sort by component
matur_comps_norm_df_sort <- matur_comps_norm_df[order(matur_comps_norm_df$component),]
row.names(matur_comps_norm_df_sort) <- NULL # reset row indices after sorting

# extract and save component-wise gradient values
for (i in 1:max(matur_comps_norm_df$component)) {
  temp_comp_df <- subset(matur_comps_norm_df_sort, component==i, select=c(child, adolescent, adult))
  temp_comp_df <- melt(temp_comp_df, measure.vars=1:3, variable.name="gr", value.name="obs", na.rm=T, variable.factor=T)
  filename <- paste0("c",i,"_grps_gradient_na-rm_long.csv")
  write.table(as_tibble(temp_comp_df), file=file.path(out_dir,filename), sep=",", row.names=F, col.names=T)
}
