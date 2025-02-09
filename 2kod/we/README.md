2d_v00:
    * 100ps tau
    * 2 pcoords:
        * Binding RMSD (aligning to M1 and taking RMSD of M2) of W184 and M185
            * pick the larger value of both M1-M2 and M2-M1 RMSDs
                * taking advantage of the homodimer symmetry
            * tracking both as aux data to get the continuous pdist later
        * COM distance between the two dimers, not including flexible c-terminal tail
            * but including the flexible n-terminal tail, I feel this might be important
    * Also tracking the minimum distance between the monomers
        * 16A box and so using a distance of 6A to be defined as separated
        * technically the third pcoord but only using with 1 bin and skipping
    * 2D MAB based binning scheme:
        * 5 x 5 bins = 25 bins
        * 5 walkers per bin
        * 125 walkers with full bin occupancy
    * Results:
        * Didn't fully unbind, once one side of the W184 and M185 pair unbound the other wasn't focused on due to the nature of the pcoord. To remedy this, I could try with the smaller of the RMSD values, which may encourage both to unbind but will be troublesome if it is a stepwise pathway. I then think it would be best to use the general RMSD of both W184 and M185 pairs, so it can be tracked together and small changes in either are encouraged but not forced.

2d_v01:
    * Same as before but with the 1st pcoord as the RMSD of both W184 and M185 pairs.
    * got some recycling events with this setup!
    * but the images are not imaged well, so strange values and events were present.

2d_v02:
    * Same as v01 but with a better autoimaging setup
    * from the autoimage cpptraj man page, for something like a protein dimer:
        * it is best to choose something in the middle of the interface, like a single residue
        * e.g. residue V181 (resid 38)
    * fixed the stripped rst output
    * using amber 22 (a100s)
        * needed to stop hard linking amber18 executables in env.sh
    
1d_v00:
    * using 2d_v02 template, but now only using COM distance as pcoord and increasing number of MAB bins
    * Saving coords every 10 ps for efficiency
    * Using 8 walkers per bin instead of 5
    * 20 1d bins instead of 5x5 2d
    * fixed pcoord 1 and 2 saved to aux naming

2d_v03:
    * using 1d_v00 as template
    * running 5 x 5 2d MAB with 8 walkers per bin
    * I still had some imaging issues, I think it is due to the dimers separating too much, then the center of the box is no longer the interface residue choosen. I will need to use unwrap and COM based imaging.
    * Had to truncate from 372 to 250 since recycling didn't work since I used -inf and inf for int ene bin. 

2d_v04:
    * using 2d_v03 as template
    * updated imaging to use unwrap and center on dimer COM then image

2d_v05:
    * using 2d_v04 as template
    * for some reason, v04 had a weird bug where the int ene jumped to zero
    * I'm running the same thing again to see if it was a one time thing, but more likely it was because of the imaging, let's find out.
    * also testing out using 300kT weight threshold
    * so I ran ~100 iterations and the same issue with int ene is happening
    * so lets go back to the anchor point style imaging and see if it works better

1d_v01:
    * used 1d_v00 as template
    * this is to be used for my ML class to select an optimized pcoord
    * changed to equilibrium, so no recycling
    * had to fix and adjust some other things:
        * updated a seg.rst in runseg to ncrst to be consistent (overall for mdtraj)
        * changed rms_key from pcoord to rms_184_185
        * added min_dist pcoord to aux data
        * updated directory for 2kod and 1a43 refs since I removed the ix/hiv1_capsid parent dir

1d_v02:
    * same as 1d_v01 except using 4 segs per bin for faster run time

1d_v03:
    * from 1d_v01 and 1d_v02, it seems like the equil don't have as much of a chance to unbind compared to the ssWE run from 1d_v00, but this is a small sample size.
    * this time I am going to try to get alot of trajectory variation for good ML input data
    * so I will use a rectilinear binning scheme from ~20-35A com distance and then MAB
    * also changed back to 8 walkers per bin

1d_v04:
    * from 1d_v03 as template
    * changing to a 2 mab 1d binning scheme
    * also changing back to ssWE
    * this works pretty well
    * note that the recycling conditions didn't work that well
        * this may be due to no recycling in other MAB bin, fixed this in tstate.file
        * however, after running more iterations after 500 with new tstate.file, it still didn't seem to be working

1d_v05:
    * from 1d_v04 as template
    * putting a cap on MAB com distance at 50A
    * also putting min cap at 20A
    * using less walkers per bin (8-->4)
    * but using more bins (30 from 20-35 and 10 from 35-50)

1d_v06:
    * from 1d_v04 as template
    * maybe using the new tstate file recycling will work here
    * now using 30 for first MAB bin and 5 for second MAB bin
    * also including the W184 to opposing monomer distances as aux data
        * that is, the W184 to opposing monomer distance matrices

ml_v00:
    * from 1d_v06 as template
    * this uses the weighted average of the W184 (M2) to M1 residue distances as pcoord
        * instead of before, using the COM M1-M2 distance
    * so still a 1D pcoord, 30 MAB bins 0-inf
        * and 2nd skipped pcoord for recycling (>6A min contact distance)
        * updated tstate.file since don't need two recycling bins anymore
    * 4 walkers per bin
    * RESULT after 500i: didn't work too well...
        * perhaps if I use the product of the M1W184 and M2W184 dmat weighted avgs?

ml_v01:
    * ml_v00 as template
    * added the other set of W184 to opposing monomer residues 1D distance matrix
    * using both weighted averages (product of them) as the new pcoord

ml_v02:
    * used ml_v01 as template
    * updated weights to sum of squares based ml_pcoord with 50 n_succ
    * using the weighted difference matrix at each timepoint
        * and adding a zero to the first element
    * still taking the product of the m1w184-m2 and m2w184-m1 w_avg values

ml_v03 :
    * ml_v02 as template
    * using ml_pcoord and com distance with mab in each

2d_v06:
    * using ml_v03 as template
    * NOTE: needed to update min_dist calc, should be including H atoms but was not before
    * from the min_dist dataset, the inter-contacts may be a good pcoord for intial unbinding
    * so, running a 2D WE using: 
        1) n inter-contacts of all atoms 
        2) com distance
    * also no longer removing the link to parent.ncrst, which can be useful later on
    * adding nc and nnc from min_dist to aux data

ml_v04 and ml_v05:
    * using 2d_v06 as a template
    * v04 will use PC1 and PC2 as pcoords
    * v05 will use tIC1 and tIC2 as pcoords
    * using pkl file from fitted models using succ traj 500_29 from 1d_v06
        * used the phi/psi dihedral angle space converted to sin/cos coordinates
    * stopped collecting dmat data as aux
    * added PC1/PC2/tIC1/tIC2 as aux data
    * adjusted mab directions depending on component plots
   
