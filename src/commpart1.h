#ifndef COMMPART1_H
#define COMMPART1_H

#include "adios2Routines.h"
#include "testutilities.h"
namespace coupler {

class Part1ParalPar3D {
  public:
    LO mype ; // my process rank in mpi_comm_world
    LO mype_x; // my process rank in comm_x
    LO mype_y; // my process rank in comm_y
    LO mype_z; // my process rank in comm_z
    MPI_Comm comm_x;
    MPI_Comm comm_y;
    MPI_Comm comm_z;
    MPI_Comm comm_cart;
    LO  NP; // The total number of processes
    LO npx,npy,npz;
    LO nx0,nxb,li0,li1,li2,lg0,lg1,lg2;
    LO ny0,nyb,lj0,lj1,lj2,lm0,lm1,lm2;
    LO nz0,nzb,lk0,lk1,lk2,ln0,ln1,ln2;
//    LO myli0,mylj1,myl12;  // The indexes of box y after Fourier transform
    int periods[3]={0,1,1};
    double* xcoords=NULL; // The 1d array storing the radial position of all flux surfaces
    double* pzcoords=NULL; // The 1d array storing the poloidal angle of all vertices along the poloidal surface curve.
    double* pzp=NULL; // The 1d array storing the poloial on each process.
    double dz;  // The equal step length along the poloidal flux curve.
 // parameters for creating the magnetic field, density and temperature ground. 
    LO res_fact;
    Array1d<int>* parpar;
    Array1d<double>* xzcoords;
    /* constructor
     * optionally read preproc, test_case and test_dir from user
     */
    Part1ParalPar3D(Array1d<int>* parpar_, Array1d<double>* xzcoords_,
		    bool pproc = true,TestCase tcase = TestCase::off,
      		    std::string tdir="")
      : preproc(pproc), test_case(tcase),
	    parpar(parpar_),xzcoords(xzcoords_) {
      init(tdir);
    }
    ~Part1ParalPar3D()
    {
      if(xcoords!=NULL)  delete[] xcoords;
      if(pzcoords!=NULL) delete[] pzcoords;
      if(pzp!=NULL)      delete[] pzp;
    }
    
  private:
    const bool preproc;
    const TestCase test_case;
    void init(std::string test_dir="");
    void initTest0(std::string test_dir);
    /* init* helper function */
    void CreateSubCommunicators();
    /* destructor helper function */
    void MpiFreeComm();
};

}

#endif