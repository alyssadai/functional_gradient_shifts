#!/bin/bash

# Description: A small helper script for converting hemisphere-specific gifti files of a specified gradient map into a whole-brain .txt file containing vertex-wise gradient values.
# Requires: connectome-workbench
# Example usage: ./gradient_gii_to_txt.sh adolescent_Gradient1_den-41k_lh_civet.gii adolescent_Gradient1_den-41k_rh_civet.gii adolescent_gradient1_den-41k_civet

gradient_gii_lh=$1  # left hemisphere gifti
gradient_gii_rh=$2  # right hemisphere gifti
gradient_name=$3    # gradient name

wb_command -cifti-create-dense-scalar ${gradient_name}_LR.dscalar.nii -left-metric ${gradient_gii_lh} -right-metric ${gradient_gii_rh}
wb_command -cifti-convert -to-text ${gradient_name}_LR.dscalar.nii ${gradient_name}_LR.txt
