"""
Overlaid 1D avg pdist plots.
"""

import wedap
import numpy as np
import matplotlib.pyplot as plt

plt.style.use("/ihome/lchong/dty7/Apps/wedap/wedap/styles/default.mplstyle")

fig, ax = plt.subplots()

dt = "average"

# plot 1 of PCs
plot = wedap.H5_Plot(h5="ml_v04/west.h5.i158", data_type=dt, plot_mode="line", Xname="com_dist", xlim=(18, 60), ax=ax, xlabel="COM Distance (Å)", data_label="PCA").plot()

# plot 2 of tICs
plot = wedap.H5_Plot(h5="ml_v05/west.h5", data_type=dt, plot_mode="line", Xname="com_dist", xlim=(18, 60), ax=ax, xlabel="COM Distance (Å)", data_label="tICA").plot()

# plot 3 of ROCAUC opt
plot = wedap.H5_Plot(h5="ml_v00/west.h5", data_type=dt, plot_mode="line", Xname="com_dist", xlim=(18, 60), ax=ax, xlabel="COM Distance (Å)", data_label="ROCAUC Opt").plot()

# plot 4 of naive com dist pcoord
plot = wedap.H5_Plot(h5="1d_v00/west.h5", data_type=dt, plot_mode="line", Xname="pcoord", xlim=(18, 60), ax=ax, xlabel="COM Distance (Å)", data_label="COM Pcoord").plot()

# plot 5 of man opt pcoord
plot = wedap.H5_Plot(h5="2d_v06/west.h5", data_type=dt, plot_mode="line", Xname="com_dist", xlim=(18, 60), ax=ax, xlabel="COM Distance (Å)", data_label="Manual Opt").plot()

plt.legend()
plt.show()
