"""
Returns a product of the 1D input vectors.
"""

import numpy as np
import sys

f1_in = str(sys.argv[1])
f2_in = str(sys.argv[2])
f_out = str(sys.argv[3])

# arg 1 = file path
f1 = np.loadtxt(f1_in)
# arg 2 = file path
f2 = np.loadtxt(f2_in)

# make script work for get_pcoord and runseg n_dims
f1 = np.atleast_2d(f1)
f2 = np.atleast_2d(f2)

# multiply the two arrays 
pdt = np.multiply(f1, f2).reshape(-1,1)

# write out new data file
np.savetxt(f_out, pdt)
