import numpy as np

def adjust_plot(hist, midpoints, binbounds):
    import matplotlib.pyplot as pyplot
    import h5py
    # First adjust axis labels
    pyplot.xlabel(r"Heavy Atom RMSD ($\AA$)")
    #pyplot.ylabel("WE Iteration")

    pyplot.xlim(1.5,8.5)
