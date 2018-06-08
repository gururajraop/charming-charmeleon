# 3D Mesh Generation and Texturing

## Requirements
* CMake
* Eigen 3
* OpenCV 3.0 or higher
* VTK 6.3
* PCL 1.7.2

## How to build and run

#### building the code
go to the current repository. Make sure the 3D frame data (8 frames) are availabe
```
mkdir build && cd build
cmake ../
make -j4
```
This should generate the "final" excutable in the build folder.

To run the application
```
./final <path_to_3DFrames> <meshing_alogorithm_type> <texture_type>
```

For meshing algorith types, enter 0 for Poisson and 1 for Marching Cubes
For texture support type t, and f for no texture support
