all: MPI

MPI:
	Rscript ./builder/build.r mpi

COMM:
	Rscript ./builder/build.r comm

PROF:
	Rscript ./builder/build.r prof

IO: MPI
	Rscript ./builder/build.r io
