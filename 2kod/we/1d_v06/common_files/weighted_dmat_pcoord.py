"""
Calculate a pcoord based on the ML-weighted 1D distance matrix.
"""

import numpy as np

# load in the 1D distance matrix (W184 to all alt monomer distances)
# skipping the first column (which is the frame number)
distances = np.loadtxt("m2w184_m1_dmat.dat")[:,1:]
# load in the weights from ml_pcoord
weights = np.loadtxt("m2w184_m1_dmat_weights.txt")

# number of frames from rows of 1D distance matrix
n_frames = distances.shape[0]

# distances is n_frame rows by n_res cols
# need to map this to just n_frame vals (weighted average of all n_res distances)
# first make empty array to be filled with weighted averages of size n_frames
w_avgs = np.zeros((n_frames))

# calculate the weighted average per frame and fill out the w_avgs array
for frame in range(n_frames):
    w_avg = np.sum(np.multiply(distances[frame], weights))
    w_avgs[frame] = w_avg

# save the weighted average value per frame to text file
np.savetxt("w_avgs.txt", w_avgs)