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

from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis

#from pyemma.coordinates import tica
from deeptime.decomposition import TICA

class DR_Pcoord:
    """
    Dimensionality reduction based pcoord.
    """
    def __init__(self, data, data_type="cpp", prmtop=None, dim_reduction="pca", 
                 lagtime=10, scaler="standard", n_components=1, angle_data=False):
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
        scaler : str
            Method of scaling data: default `StandardScaler`.
        n_components : int
            Returns n_components amount of e.g. PCs or TICs.
        angle_data : bool
            Default False, set True to convert angle to sin/cos pair.
        """
        self.data = data
        self.data_type = data_type
        self.prmtop = prmtop
        self.dim_reduction = dim_reduction
        self.lagtime = lagtime
        self.scaler = scaler
        self.n_components = n_components
        self.angle_data = angle_data

    def scale_data(self):
        """
        Apply data scaling.
        TODO: add options for alternative scaling.
        """
        scaler = StandardScaler()
        self.data = scaler.fit_transform(self.data)

    def _proc_angle_data(self):
        """
        Periodic angles (e.g. dihedrals) near periodic boundaries will
        behave poorly since -179° and 179° are actually only 2° away.
        This converts a single angle to radians, then returns the 
        sin and cos of the radians.
        """
        # conver to rads
        data_rad = self.data * np.pi / 180
        # convert to cos and sin
        data_rad_cos = np.cos(data_rad)
        data_rad_sin = np.sin(data_rad)
        # sin and cos arrays: χ(i) = cos(θ(i))x + sin(θ(i))y
        #data_norm = np.linalg.norm()
        # stack sin and cos arrays:
        # dPCA paper does this as well: https://doi.org/10.1063/1.2945165
        data_rad_cos_sin = np.hstack((data_rad_cos, data_rad_sin))
        # return and save
        self.data = data_rad_cos_sin
        return self.data

    def proc_cpp_data(self, scale=True):
        """
        Process input cpptraj calculated data.
        """
        # skip first column since this is the frame values
        self.data = np.loadtxt(self.data)[:,1:]
        self.frames = np.arange(0, self.data.shape[0])
        if self.angle_data:
            self._proc_angle_data()
        # eventually move to main public method
        if scale:
            self.scale_data()
        return self.data

    def proc_coords_data(self):
        """
        Process input md coordinate data.
        """
        traj = mdtraj.load(self.data, top=self.prmtop)
        #self.data = np.squeeze(traj.xyz)
        self.data = traj.xyz.reshape(traj.n_frames, traj.n_atoms * 3)
        self.frames = np.arange(0, traj.n_frames)
        self.scale_data()
        return self.data

    def run_pca(self):
        """
        Reduce data using pca.
        """
        pca = PCA(n_components=self.n_components)
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
        tica = TICA(dim=self.n_components, lagtime=self.lagtime).fit(self.data)
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
        lda = LinearDiscriminantAnalysis(n_components=self.n_components)
        lda.fit(self.data, y)
        self.proj = lda.transform(self.data)
        self.model = lda
        print(lda.explained_variance_ratio_)
        return self.proj

    def get_proj_data(self):
        """
        Main public method. Runs dimensionality reduction and returns
        the dataset projected onto reduced dimensionality space.
        Maybe this class isn't needed, better to use the methods on their own?
        """
        if self.data_type == "pca":
            self.run_pca()

if __name__ == "__main__":
    
    # TODO: optimize lagtime with some metric? prob ITS plot
    # Also, will prob be better to use more data, i.e. of all succ trajs

    #ml = DR_Pcoord("m1w184_m2_ca_dmat.dat", lagtime=10, n_components=2)
    #ml = DR_Pcoord("m2w184_m1_ca_dmat.dat", lagtime=10, n_components=2)
    #ml = DR_Pcoord("chip.dat", lagtime=10, n_components=2, angle_data=True)
    #ml = DR_Pcoord("phi_psi_chip.dat", lagtime=10, n_components=2, angle_data=True)

    # best coord set
    # ml = DR_Pcoord("phi_psi.dat", lagtime=10, n_components=2, angle_data=True)
    # ml.proc_cpp_data(scale=True)
    # ml.run_pca()
    # #ml.run_tica()
    # plt.scatter(ml.proj[:,0], ml.proj[:,1], c=ml.frames, s=5)
    # plt.colorbar()

    #print(ml.model.timescales.shape)

    import pickle
    # write binary pkl file
    # with open('pca.pkl', 'wb') as handle:
    #     pickle.dump(ml, handle, protocol=pickle.HIGHEST_PROTOCOL)

    plt.style.use("/Users/darian/github/wedap/wedap/styles/default.mplstyle")
    # read binary pkl file
    with open('pca.pkl', 'rb') as handle:
        ml = pickle.load(handle)
    plt.scatter(ml.proj[:,0], ml.proj[:,1], c=ml.frames, s=5)
    plt.xlabel("PC 1")
    plt.ylabel("PC 2")
    # load transform new loaded data test
    #ml2transform = DR_Pcoord("phi_psi.dat", lagtime=10, n_components=2, angle_data=True)
    #ml2transform.proc_cpp_data()
    #new_proj = ml.model.transform(ml2transform.data)
    # np.savetxt("tIC1.dat", new_proj[:,0])
    # np.savetxt("tIC2.dat", new_proj[:,1])

    # this might be useful for maximizing each small boundary of +/- n iterations
    # could optimize the lda score
    # y = np.zeros((5000))
    # y[2500:] = 1
    # plt.plot(ml.run_lda(y=y))
    

    # for md coord data
    # ml = DR_Pcoord("../500_29_auto.nc", data_type="coords", prmtop="2kod_m01_dry.prmtop", lagtime=100)
    # ml.proc_coords_data()
    # plt.plot(ml.run_pca())
    #plt.plot(ml.run_tica())

    cbar = plt.colorbar()
    cbar.set_label("Frame")
    plt.tight_layout()
    #plt.show()
    plt.savefig("pcs.pdf", transparent=True)