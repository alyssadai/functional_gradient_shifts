#!/usr/bin/env Rscript

# Description: Compares two dependent groups using the shift function. Used to compare component gradient values from adolescent and child gradient maps, since these two maps were derived from longitudinal scans of the same sample (see Dong et al., 2021).
# Outputs:
# Example usage: ./run_shiftfn_indgrps_singlecomp.R 2 adolescents children

# Load packages -----
suppressPackageStartupMessages({
  library(rogme)
  library(cowplot)
  library(ggplot2)
  library(tidyverse)
})

# Accept command-line args -----
args <- commandArgs(trailingOnly=TRUE)
comp <- as.numeric(args[1])  # component number
grp1 <- args[2]              # first gradient age group to be compared - goes on x-axis
grp2 <- args[3]              # second gradient age group to be compared - goes on y-axis

# Load data -----
comp_data <- read_csv(paste0("inputs/c",comp,"_grps_gradient_na-rm_long.csv"), col_names=T, col_types="fd")

# Rename levels for plotting -----
if (grp1 == "adolescents") {
  grp1 <- "ADOLES"
}
if (grp2 == "children") {
  grp2 <- "CHILD"
}

newlevels <- c("CHILD", "ADOLES", "ADULT")
for (l in 1:length(levels(comp_data$gr))) {
    levels(comp_data$gr)[l] <- newlevels[l]
}

comp_data <- comp_data[comp_data$gr != "ADULT",] # must remove since adults group may have unequal # obs. compared to other two
comp_data$gr <- droplevels(comp_data$gr) # drop unused level

# Compute shift function -----
set.seed(4)
sf <- shiftdhd_pbci(data = comp_data,
                   formula = obs ~ gr,
                   todo = list(c(grp1, grp2)))

# Plot shift function -----
text_tsize <- 40
title_tsize <- 46
p <- plot_sf(sf, plot_theme=2, symb_size=8, diffint_size=1, q_line_size=2, theme2_alpha = c(1,1))
p[[1]] <- p[[1]] +
          ylab(paste0(grp1," - ",grp2)) +
          theme(
            axis.title.x = element_text(size=48,face="plain"),
            axis.title.y = element_text(size=title_tsize,face="plain"),
            axis.text.y = element_text(size=text_tsize, color="black"),
            axis.text.x = element_text(size=text_tsize, color="black"),
            panel.border = element_rect(fill=NA, colour = "black", size=1),
            plot.margin = margin(1, 1, 1, 1, "cm"),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank()) # remove grid
psf <- p[[1]]

ggsave(plot=psf, filename=paste0("shiftfn_figures/c",comp,"_shiftfn_contrast_",grp1,"-vs-",grp2,".png"),
       width=12.75, height=8.25, units="in", type="cairo", dpi=300)
