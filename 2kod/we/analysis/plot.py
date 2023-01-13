"""
Plotting ctd unbinding 2d_v04.
I hope to:
    1) see the pdist at every 100 frames, which is tau
        - this will be the recycling conditions
    2) trace the recycled and not recycled pathways
        - does the traj really reach >12A min contact and come back?
        - I should also visualize these in vmd
"""

import wedap
import matplotlib.pyplot as plt

X, Y, Z = wedap.H5_Pdist("ctdub_2d_v04.h5", "average", Xindex=1, Yname="pcoord", Yindex=2, 
                         data_proc=lambda X : X[::1,:]).pdist()
# X, Y, Z = wedap.H5_Pdist("ctdub_2d_v04.h5", "evolution", Xindex=1, 
#                          data_proc=lambda X : X[::1,:]).pdist()                         
plot = wedap.H5_Plot(X, Y, Z)
plot.plot()
#plot.ax.set_xlabel("COM Distance ($\AA$)")
plt.show()