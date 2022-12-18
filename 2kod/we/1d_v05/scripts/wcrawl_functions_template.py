#!/usr/bin/env python
# 
# wcrawl_functions.py
# adjust aux_name var, nframes, data_dims, and file paths before running
#

from __future__ import print_function, division; __metaclass__ = type
import numpy
import h5py
import os
import sys
from westpa.core import h5io
from westpa.cli.tools.w_crawl import WESTPACrawler

# first set up wcrawl directory for file storage
# this directory must contain the cpptraj.temp file to be used for running analysis

aux_name = "WCRAWL_FUNCTIONS_AUX_NAME"

class IterationProcessor(object):
    '''
    This class performs analysis on each iteration.  It should contain a method
    ``process_iteration``, which may be called as 
    ``process_iteration(self, n_iter, iter_group)``, where ``n_iter`` refers to
    the weighted ensemble iteration index, and ``iter_group`` is the HDF5 group 
    for the given iteration. The method should return an array or other values, 
    which the ``process_iter_result`` method of the ``Crawler`` class recieves 
    as the argument ``result``. 
    '''
    # Store the location of the PDB file to be used as the topology 
    topology_filename = 'common_files/m01_2kod_dry.prmtop'
    # Define the pattern used for finding each segment's traj file
    iter_pattern = 'iterations/iter_{n_iter:08d}'
    traj_pattern = 'traj_segs/{n_iter:06d}/{seg_id:06d}/{filey}'
    parent_pattern = 'traj_segs/{parent_iter:06d}/{parent_id:06d}/seg-nowat.rst'
    # In this example, there are three frames saved for each segment.
    nframes = 101

    def __init__(self):
        '''
        Initialize the IterationProcessor class
        '''
#        self.workdir = os.environ('LOCAL')

    def process_iteration(self, n_iter, iter_group):
        '''
        The main analysis function that w_crawl calls for each iteration.
        This should be changed based on your analysis. This method could
        contain all the code for your analysis, or it could call an outside
        function. 

        ----------
        Parameters
        ----------
        n_iter: (int) The index of the weighted ensemble iteration for which
          analysis should be performed.
        iter_group: (H5py group) The hdf5 group corresponding to iteration
          n_iter, from the the main WESTPA data file (typically west.h5)

        -------
        Returns
        -------
        result: (numpy.ndarray) In general this could be an object, which is
          later processed by Crawler.process_iter_result. Here, it is an array
          of the center of mass of the protein. The array has shape 
          (n_segments, n_timepoints, 3), where dimension 0 indexes the segment, 
          dimension 1 indexes the frame number, and dimension 2 indexes the 
          x/y/z coordinate of the center of mass.
        '''
        global aux_name
        # Find the number of segments in the iteration at hand
        print("starting",n_iter)
        nsegs = iter_group['seg_index'].shape[0]
        parent_iter = n_iter-1
        #f = h5py.File("./west.h5")

        # The dimensionality of the data you wish to store
        # this creates a 3D array
        data_dims = 1
        
        # Create an array to hold your data
        #iteration_data_array = numpy.zeros((nsegs, self.nframes, data_dims))
        iteration_data_array = numpy.zeros((nsegs, self.nframes))
        print("Iteration Data Array: ", iteration_data_array.shape)

        # Iterate over each segment
        for iseg in range(nsegs):
            print(iseg)
            pathy = self.iter_pattern.format(n_iter=n_iter)
            with h5py.File("./west.h5") as f:
                parent_seg = int(f[pathy]['seg_index']['parent_id'][iseg])
            if parent_seg < 0:
                parent_seg = parent_seg*-1
            # Generate a path to the traj file
            parentpath = os.path.join(os.environ['WEST_SIM_ROOT'], self.traj_pattern.format(n_iter=parent_iter,seg_id=parent_seg,filey="seg-nowat.rst") )
            trajpath = os.path.join(os.environ['WEST_SIM_ROOT'], self.traj_pattern.format(n_iter=n_iter,seg_id=iseg,filey="seg.nc") )

            # Open up the traj file for the segment
            fin = open("wcrawl/CPP_TEMP_ID.temp", 'rt') 
            data = fin.read()
            if n_iter == 1:
                data = data.replace('PARENT', 'bstates/06_prod_dry.rst')
            else:
                data = data.replace('PARENT', parentpath)
            #data = data.replace('PARENT', parentpath)
            data = data.replace('TRAJ', trajpath)
            data = data.replace('TOP', self.topology_filename)
            data = data.replace('AUX_NAME', "wcrawl/" + aux_name)
            fin.close()
            fout = open(f"wcrawl/{aux_name}_{n_iter}_{iseg}.in", 'wt') 
            fout.write(data)
            fout.close()
            cpptrajcommand = f"cpptraj -i wcrawl/{aux_name}_{n_iter}_{iseg}.in >/dev/null 2>&1"
            os.system(cpptrajcommand)
            os.remove(f"wcrawl/{aux_name}_{n_iter}_{iseg}.in")
            xs = []
            with open(f"wcrawl/{aux_name}.dat", 'r') as f:
                lines = f.readlines()[1:]
                for x in lines:
                     xs.append(float(x.split()[1]))

            # Iterate over each timestep and calculate the quantities of interest.
            for num, val in enumerate(xs):
                #print(num,val)
                # Run some calculation here and add the result for the current 
                # timestep to the array for the whole iteration
                # Here, I calcualte the center of geometry since it is easy to
                # calculate; you can make this analysis as complex as you need
                #iteration_data_array[iseg, num - 1 ] = val
                iteration_data_array[iseg, num] = val

        return iteration_data_array

class Crawler(WESTPACrawler):
    '''
    In this example, w_crawl works as follows:

    We supply the ``Crawler`` class, which handles writing data. The 
    Crawler specifies 3 methods: initialize, finalize, and process_iter_result.

    ``initialize`` is called only once--when w_crawl starts up. The job of 
    initialize is to create the output file (and HDF5 file).

    Like ``initialize``, ``finalize`` is also called only once--when w_crawl
    finishes calculations for all iterations. The job of ``finalize`` is to
    gracefully close the output file, preventing data corruption.

    The method ``process_iter_result`` is called once per weighted ensemble
    iteration. It takes the weighted ensemble iteration (n_iter) and the result
    of the calculations for an iteration (result) as arguments, and stores the
    data in the output file.

    The actual calculations are performed by the IterationProcessor class 
    defined above. In particular, the IterationProcessor.process_iteration 
    method performs the calculations; the return value of this method is passed
    to Crawler.process_iter_result.
    '''

    def initialize(self, iter_start, iter_stop):
        '''
        Create an HDF5 file for saving the data.  Change the file path to
        a location that is available to you. 
        '''
        global aux_name
        self.output_file = h5io.WESTPAH5File(f'wcrawl/{aux_name}.h5', 'w')
        h5io.stamp_iter_range(self.output_file, iter_start, iter_stop)

    def finalize(self):
        self.output_file.close()

    def process_iter_result(self, n_iter, result):
        '''
        Save the result of the calculation in the output file.

        ----------
        Parameters
        ----------
        n_iter: (int) The index of the weighted ensemble iteration to which
          the data in ``result`` corresponds.
        result: (numpy.ndarray) In general this could be an arbitrary object
          returned by IterationProcessor.process_iteration; here it is a numpy
          array of the center of geometry.
        '''
        global aux_name
        # Initialize/create the group for the specific iteration
        iter_group = self.output_file.require_iter_group(n_iter)

        iteration_data_array = result
        
        # Save datasets
        dataset = iter_group.create_dataset(aux_name, 
                                            data=iteration_data_array, 
                                            scaleoffset=6, 
                                            compression=4,
                                            chunks=h5io.calc_chunksize(
                                                    iteration_data_array.shape,
                                                    iteration_data_array.dtype
                                                                       )
                                            )

# Entry point for w_crawl
iteration_processor = IterationProcessor()
def calculate(n_iter, iter_group):
    '''Picklable shim for iteration_processor.process_iteration()'''
    global iteration_processor 
    return iteration_processor.process_iteration(n_iter, iter_group)

crawler = Crawler()
