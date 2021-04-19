# speciome-peregrine

This collection of scripts helps launching many parallel runs of the `speciome` simulation program (link [here](https://github.com/rscherrer/speciome)) directly on the [Peregrine](https://www.rug.nl/society-business/centre-for-information-technology/research/services/hpc/facilities/peregrine-hpc-cluster?lang=en) high performance cluster from the University of Groningen, the Netherlands. 

## About

The scripts provided are written in Bash and Python. To use them, it is assumed that you have an operational account on the Peregrine cluster and you can submit jobs.

Note: to run the shell scripts, e.g. `script.sh`, use either `./script.sh` or `bash script_name.sh`.

## Instructions

### Clone the repository

First, log in onto the Peregrine cluster and clone this repository anywhere you like, using:

```{bash}
git clone https://github.com/rscherrer/speciome-peregrine
```

That said, I advise you to do that on the partitions `/data` or `/scratch`, which have a large storage capacity, in view of the large amount of data you may produce.

### Update your bash profile

For `speciome` to be compiled and deployed over many simulations some specific packages must be added to your session first:

```
module add Python/3.6.4-foss-2018a
module add libpng/1.6.37-GCCcore-8.3.0
module add PCRE2/10.33-GCCcore-8.3.0
module add double-conversion/3.1.5-GCCcore-9.3.0
```

Alternatively, you can run the `updateProfile` to add these commands directly into your `.bash_profile`, located in `/home/$USER`. Once added to your profile, these commands will be executed every time you log into your session. You can manually delete them from the `.bash_profile` anytime you want.

### Download the program

Now clone the `speciome` repository by running the `cloneSpeciome.sh` script. The source code of the program will be downloaded in the working directory. You can go into the `speciome` repository and checkout another branch than the default branch if need be.

### Build the program

Build an executable for `speciome` by running the `buildTarget.sh` script followed by the name of the _target folder_ where the executable should be moved. The idea is that the target folder is where all the simulations will be stored. Note that you can also compile the executable from source yourself using your favorite compiler. Try to run `buildTarget.sh` from within `speciome-peregrie`, as it assumes that the `speciome` folder is directly accessible from the working directory. This script will move the compiled executable, as well as other relevant files, into the target folder.

### Prepare a protocol

Move into the target folder (using `cd`). From there you can use the `runSimulations.sh` script to launch many simulations, but this script requires a _protocol file_ indicating the parameter combinations to explore.

A protocol file looks like this:

```
# This is a protocol file

#SBATCH --time=00:30:00
#SBATCH --mem=32Gb
#SBATCH --partition=gelifes

-mutation 0.001 0.01
-ecosel 0.1 0.2

N=5
```

Lines starting with `#SBATCH` will be added to the header of all the _job files_ submitted. They are options to give to SLURM (the queuing system, see the documentation of the Peregrine cluster). Lines starting with a dash and a parameter name (e.g. `-mutation`) will be interpreted as values of that parameter to explore, where the different values are separated by spaces. For multiple-valued parameters use underscores to group the values within a given parameter set (e.g. `-nvertices 10_10_10 20_20_20 30_30_30`). The script `runSimulations.sh` will make use of the Python scripts to run simulations for all combinations of the parameter values provided. The last element, `N`, indicates the number of replicate simulations per parameter set (the only thing that changes then is the random seed).

The parameter values provided in the protocol file will be used to overwrite the default values in the _parameter file_ already present in the target folder. This file will be passed to the `speciome` executable upon execution. See the `speciome` documentation for details about the parameter file. Parameters that are not mentioned in the protocol file will not be overwritten.

### Launch the simulations

Run the `runSimulations.sh` script with its corresponding protocol file (e.g. `./runSimulations.sh protocol.txt`) from within the target folder. This should create a _simulation folder_ for each of the required simulations and launch each simulation by submitting a job file to SLURM from within each of these folders, using the `speciome` executable in the target folder.

To monitor the advancement of your jobs, use the classic `sequeue -u $USER`. To cancel all your jobs, use `scancel -u $USER`.

### Re-run simulations

Run the `rerunSimulations.sh` script from within the target folder to re-run some simulations. This script should be followed by the name of a _rerun file_, a text file containing a list of names of the folders whose simulations must re-run.
