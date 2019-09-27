###########################################################################
### architecture dependent GENE makefiles, supermuc version             ###
### http://www.lrz.de/services/compute/supermuc/                        ###
###########################################################################
#									  #
# the following modules have to be loaded first, e.g. in                  #
# $HOME/.modules/bash                                                     #
#              
MODULELIST_INTEL=intel/17.0 mkl/2017 fftw/serial petsc-complex/3.9.1c_gene
# export SLEPC_DIR=/home/hpc/pr27fe/lu65nut2/tmp/slepc-3.9.1       #
# 									  #
# IBM MPI:			         				  #
# module load poe/1.2 mpi.ibm/1.2					  #
#								          #
###########################################################################
### SWITCHES                                                            ###
###########################################################################

COMPILER=intel

# comment the following two lines for use of Intel MPI
MPFC = mpif90
MPCC = mpicc

# FFTLIB - needed in /src/files.mk
# set to: mkl, fftw or essl
FFTLIB = fftw
PRECISION= double
OPENMP = no

MPI_IO = yes
SLEPC = yes
# has to be switched on
SCALAPACK = yes
DEBUG = no
INCLUDE_SYMBOLS = no
COMPILER_REPORTS=no
USE_PERFLIB = none
FUTILS = no
PRODRUN = yes
MKLVERSION = 2017

#memory per core
MB_PER_CORE=1400

###########################################################################
#   COMPULSORY LIBRARIES						  #
###########################################################################
CHIP = SandyBridge
MKLROOT = $(MKL_BASE)

#INCLUDE PATHS
#Add include paths for BLAS routines (can be LAPACK,ESSL,MKL,etc.)
INCPATHS = -I$(OBJDIR) -I. -I$(SRCDIR)

#LIBRARIES AND LIBFLAGS

### FFT LIBRARY
ifeq ($(FFTLIB),mkl)
 INCPATHS +=
endif
ifeq ($(FFTLIB),fftw)
#FFTW seems to be faster than MKL when single precision is used
#further tests needed
   INCPATHS += $(FFTW_INC)
   LIBS += $(FFTW_LIB)
endif

###########################################################################
# ADDITIONAL LIBRARIES (set via SWITCH in header)			  #
###########################################################################

ifeq ($(SLEPC),yes)
  ifeq ($(PRECISION),double)
   ifeq (,$(wildcard $(SLEPC_DIR)/lib/slepc/conf/slepc_common))
    include $(SLEPC_DIR)/conf/slepc_common
   else
    include $(SLEPC_DIR)/lib/slepc/conf/slepc_common
   endif
   INCPATHS +=$(PETSC_FC_INCLUDES) $(SLEPC_INCLUDE)
#  compiling with SLEPc requires libsvml to avoid unresolved dependencies
   LIBS += -L$(INTEL_BASE)/compiler/lib/intel64 -lsvml
   LIBS += $(SLEPC_LIB)
   PREPROC += -DWITHSLEPC
  else
   SLEPC=no
  endif
endif

ifeq ($(SCALAPACK),yes)
  LIBS += $(MKL_SCALAPACK_LINKLINE)
else
  LIBS += $(MKL_BLAS_LINKLINE)
endif

ifeq ($(FUTILS),yes)
 #  FUTILS and HDF5
 FUTILSDIR = $(EXTDIR)/$(MACHINE)/futils/src
 HDF5PATH = $(HDF5_HOME)
 HDF5_LIBPATH  = -L$(HDF5PATH)/lib -L$(FUTILSDIR)
 HDF5_LIBS = -lfutils -lhdf5_fortran -lhdf5 -lz 

 LIBS += $(HDF5_LIBPATH) $(HDF5_LIBS)
 PREPROC +=  -DWITHFUTILS
 INCPATHS += -I$(FUTILSDIR)
endif


###########################################################################
### COMPILER & COMPILER FLAGS                                           ###
###########################################################################

ifeq ($(USE_PERFLIB),perf)
 LIBS += $(PERFLIB_TS)
 PREPROC += -DWITHPERF=1
else
ifneq ($(USE_PERFLIB),none)
 PREPROC += -DWITHPERF
endif
endif

#LDFLAGS += -Xlinker -M

###########################################################################
### Running                                                             ###
###########################################################################
MPRUN = export OMP_NUM_THREADS=1;\
	export MKL_SERIAL=yes;\
	mpiexec -n $(N_PES) ./$(EXEC)

###########################################################################


###########################################################################
### Machine dependent compiling rules                                   ###
###########################################################################

NOOPTLIST= 

preproc: $(F90PRENAMES) $(PPDIR)/gene.f90