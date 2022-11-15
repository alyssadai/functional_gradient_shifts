# Description: Z-scores a user-specified gradient map, appends column of component labels, and removes midline vertices (but not vertices where the gradient value is nan).
# Outputs: 1) .txt file containing component labels and z-scored gradient values of non-midline vertices 2) .txt file with z-scored gradient values of all vertices, for visualization
# Example usage: python zscore_gradient_maps.py maturational_gradients/adolescent_gradient1_den-41k_LR_civet.txt adolesc-gradient1 LR_components_labels.txt

import numpy as np
import pandas as pd
import sys
from sklearn.preprocessing import MinMaxScaler, StandardScaler
import scipy.stats as stats

# accept command-line inputs
gradient_file_path = sys.argv[1]    # path to gradient map file, e.g. adolescent gradient 2 from Dong et al., 2021
gradient_name = sys.argv[2]         # arbitrary short gradient name, for saving zscored outputs
comp_labels_path = sys.argv[3]      # path to file containing component labels of each vertex

out_dir = "gradient_maps_zscore"
gradient_file = np.loadtxt(gradient_file_path)

# z-score
gradient_scaled = gradient_file.copy()
gradient_scaled[~np.isnan(gradient_file)] = stats.zscore(gradient_file[~np.isnan(gradient_file)])

# create dataframe with vertex-wise component assignments & gradient values for plotting violin plots
df = pd.read_csv(comp_labels_path, header = None, names = ["component"])

# add gradient values to dataframe
df['gradient'] = gradient_scaled

# remove midline vertices
df = df.loc[df['component'] != 0]

# save files
df.to_csv(f"{out_dir}/merged_LR_comp-labels_{gradient_name}_zscore_nomidline.txt", sep = " ", na_rep="nan", float_format = "%.6f", header = False, index = False)
np.savetxt(f"{out_dir}/{gradient_name}_zscore_civet_41k_LR.txt", gradient_scaled, fmt="%.6f") # for visualization
