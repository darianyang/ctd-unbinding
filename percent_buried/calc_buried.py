"""
Use MDTraj to calculate the SASA in monomer vs dimer.
From the differnce, can see which residues are most buried
in the CTD dimer interface.
"""

import numpy as np
import matplotlib.pyplot as plt
import mdtraj as md

def calc_per_residue_sasa(pdb):
    """
    Return per-residue SASA from mdtraj.

    Parameters
    ----------
    pdb : str
        Path to pdb file
    
    Returns
    -------
    sasa : array
        SASA of each residue.
    """
    # create mdtraj traj object
    traj = md.load(pdb)

    # calc sasa using the shrake_rupley method
    sasa = md.shrake_rupley(traj, mode="residue")

    return sasa

def calc_percent_buried(ctd_name, ax):
    """
    Take the difference of the per-residue SASA.

    Parameters
    ----------
    ctd_name : str
        '1a43' or '2kod'.
    """
    monomer_sasa = calc_per_residue_sasa(f"{ctd_name}_monomer.pdb")
    dimer_sasa = calc_per_residue_sasa(f"{ctd_name}_dimer.pdb")
    diff_sasa = monomer_sasa[0] - dimer_sasa[0][:88]
    #print(len(monomer_sasa[0]), len(dimer_sasa[0][:88]))
    # convert from nm^2 to A^2
    diff_sasa = diff_sasa * 10**2

    ax.bar(range(144,232), diff_sasa)
    ax.set_ylabel("Buried In Dimer ($\AA$)")
    ax.set_xlabel("Residue")
    ax.set_title(ctd_name)
    
    print(dict(zip(range(144,232), diff_sasa)))
    return diff_sasa

fig, ax = plt.subplots(figsize=(9,4), ncols=2, sharey=True)
calc_percent_buried("2kod", ax[0])
calc_percent_buried("1a43", ax[1])
plt.show()