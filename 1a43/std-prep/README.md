Note that first solvated 1a43 pdb to be close to 2kod values (solv)
then edited in parmed to be exact (solv2)
then made pdb in cpptraj to confirm the number of lines/atoms is consistent (solv3)

Note that I had to update the solv2 inpcrd file last line of box dimensions:
before used rounded numbers from PDB
changed to:
102.0156672 102.0156672 102.0156672 109.4712190 109.4712190 109.4712190
(from 2kod m01 inpcrd)
