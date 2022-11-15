# Description: Plots component-specific gradient values from a given gradient map as violin+box plots. Removes NA values internally.
# Example usage: python make_gradient_violin_plot.py gradient_maps_zscore/merged_LR_comp-labels_adult-gradient1-values_zscore_nomidline.txt figures/adult-gradient1_zscore_k8_violinplot.png 1 palette_hex.txt
# Note: input file should not include midline vertices

import numpy as np
import pandas as pd
import matplotlib as mpl
#mpl.use('tkagg')
import matplotlib.pyplot as plt
plt.switch_backend('Agg')
import seaborn as sns
import sys

in_file = sys.argv[1]       # gradient map .txt file containing 2 columns: 1) vertex component labels 2) vertex gradient values
out_file = sys.argv[2]      # file path for output plot
gradient_num = sys.argv[3]  # gradient number (e.g. 1 for gradient 1, 2 for gradient 2)
palette_path = sys.argv[4]  # path to .txt files with k hex codes to use for k component violin plots

mypalette = np.genfromtxt(palette_path, delimiter=',')
gradient_df = pd.read_csv(in_file, delimiter = " ", names = ["Component", f"Gradient {gradient_num}"])
gradient_df.dropna(inplace = True)

sns.set_style("ticks")

fig, ax = plt.subplots(figsize = (8,14), dpi = 300)

sns.violinplot(ax = ax, x=f"Gradient {gradient_num}", y="Component", orient="h", data=gradient_df,
                scale="count", inner=None, linewidth=0, palette=mypalette, saturation=1, zorder=1)
plt.setp(ax.collections, alpha=.9)

mygray = "#3D3D3D"
sns.boxplot(ax = ax, x=f"Gradient {gradient_num}", y="Component", orient="h", data=gradient_df,
            linewidth=0, showcaps=False, showmeans=True, showfliers=False, width=0.07,
            boxprops=dict(facecolor=mygray, zorder=10),
            medianprops=dict(color="w", linewidth=3, solid_capstyle="butt", zorder=20),
            meanprops=dict(marker="s", markeredgecolor="none", markerfacecolor="silver", markersize=6, zorder=20),
            whiskerprops=dict(color=mygray, linewidth=2, zorder=10))

ax.set_xlim([-2.5,2.5])
ax.xaxis.set_major_locator(mpl.ticker.MultipleLocator(1))
ax.tick_params(axis='x', labelsize=25)
ax.tick_params(axis='y', labelsize=25)
ax.xaxis.label.set_size(26)
ax.yaxis.label.set_size(26)
plt.gca().invert_yaxis()

plt.tight_layout()
plt.savefig(out_file, dpi=300)
