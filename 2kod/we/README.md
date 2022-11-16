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
