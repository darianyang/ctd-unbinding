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
