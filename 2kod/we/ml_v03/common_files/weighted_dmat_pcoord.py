"""
Calculate a pcoord based on the ML-weighted 1D distance matrix.
"""

import numpy as np
import sys

# args 1, 2, and 3 needed
dmat_file = str(sys.argv[1])
weight_file = str(sys.argv[2])
outfile = str(sys.argv[3])

# load in the 1D distance matrix (W184 to all alt monomer distances)
# skipping the first column (which is the frame number)
distances = np.atleast_2d(np.loadtxt(dmat_file))[:,1:]
#print(distances.shape)

# TODO: whoops, I actually should be taking diff of axis 0, the frames
# apply same sum of squared difference operation as with ml_input
distances = np.diff(distances, axis=0)**2
#print(distances)
#print(distances.shape)
# now pad the beginning with a 0 to account for n-1 output from diff
#distances = np.concatenate((np.atleast_2d([0]), distances), axis=1)
distances = np.pad(distances, ((1,0), (0,0)), "constant")
#print(distances.shape)
#print(distances)

# load in the weights from ml_pcoord
weights = np.loadtxt(weight_file)

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
np.savetxt(outfile, w_avgs)
