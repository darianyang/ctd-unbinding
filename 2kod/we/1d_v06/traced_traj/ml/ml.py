"""
Testing different ML pcoords.

Dimensionality Reduction
------------------------
# fist try pca
# then try tica
# maybe try lda?

Try for coordinates (MDTraj) and for dmat space and dihedral space.
"""

import numpy as np
import matplotlib.pyplot as plt

import mdtraj

from sklearn.decomposition import PCA
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis

#from pyemma.coordinates import tica
from deeptime.decomposition import TICA

class DR_Pcoord:
    """
    Dimensionality reduction based pcoord.
    """
    def __init__(self, data, data_type="cpp", prmtop=None, dim_reduction="pca", lagtime=10):
        """
        Input data (coords, distances, angles, etc.) and output a per frame
        reduced dimensionality representaion of multi dimensional input data.

        Parameters
        ----------
        data : str
            Path to a data file.
        data_type : str
            Type of data to be processed:
                `cpp` : cpptraj data output 
                `coords` : MD coordinates
        prmtop : str
            Path to topology file if loading a MD coordinate file.
        dim_reduction : str
            Method for dimensionality reduction: `pca`, `tica`, `lda`.
            Note that `tica` also requires a lagtime arg.
        lagtime : int
            The lag time, in multiples of the input time step (default 10).
        """
        self.data = data
        self.data_type = data_type
        self.prmtop = prmtop
        self.dim_reduction = dim_reduction
        self.lagtime = lagtime

    def proc_cpp_data(self):
        """
        Process input cpptraj calculated data.
        """
        # skip first column since this is the frame values
        self.data = np.loadtxt(self.data)[:,1:]

    def proc_coords_data(self):
        """
        Process input md coordinate data.
        """
        traj = mdtraj.load(self.data, top=self.prmtop)
        #self.data = np.squeeze(traj.xyz)
        self.data = traj.xyz.reshape(traj.n_frames, traj.n_atoms * 3)
        return self.data

    def run_pca(self):
        """
        Reduce data using pca.
        """
        pca = PCA(n_components=1)
        pca.fit(self.data)
        self.model = pca
        self.proj = pca.transform(self.data)

        #print(self.proj.shape)
        print(pca.explained_variance_ratio_)
        return self.proj

    def run_tica(self):
        """
        Reduce data using tica
        """
        #self.proj = tica(self.data, lag=self.lagtime, dim=1).get_output()[0]
        tica = TICA(dim=1, lagtime=self.lagtime).fit(self.data)
        self.model = tica.fetch_model()
        self.proj = self.model.transform(self.data)
        return self.proj

    def run_lda(self, y):
        """
        Reduce data using lda.

        Parameters
        ----------
        y : array
            Array of decision target values.
        """
        lda = LinearDiscriminantAnalysis()
        lda.fit(self.data, y)
        self.proj = lda.transform(self.data)
        self.model = lda
        print(lda.explained_variance_ratio_)
        return self.proj

    def get_proj_data(self):
        """
        Main public method. Runs dimensionality reduction and returns
        the dataset projected onto reduced dimensionality space.
        """
        if self.data_type == "pca":
            self.run_pca()

if __name__ == "__main__":
    
    #ml = DR_Pcoord("m1w184_m2_ca_dmat.dat", lagtime=10)
    #ml = DR_Pcoord("m2w184_m1_ca_dmat.dat", lagtime=10)
    #ml = DR_Pcoord("chip.dat", lagtime=10)
    #ml = DR_Pcoord("phi_psi.dat")
    #ml = DR_Pcoord("phi_psi_chip.dat", lagtime=100)
    #ml.proc_cpp_data()
    #plt.plot(ml.run_pca())
    #plt.plot(ml.run_tica())

    # this might be useful for maximizing each small boundary of +/- n iterations
    # could optimize the lda score
    # y = np.zeros((5000))
    # y[2500:] = 1
    # plt.plot(ml.run_lda(y=y))
    

    # for md coord data
    ml = DR_Pcoord("../500_29_auto.nc", data_type="coords", prmtop="2kod_m01_dry.prmtop", lagtime=100)
    ml.proc_coords_data()
    plt.plot(ml.run_pca())
    #plt.plot(ml.run_tica())

    plt.show()