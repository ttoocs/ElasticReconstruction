cmake_minimum_required(VERSION 2.8)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/" ${CMAKE_MODULE_PATH})

#FIND THE THINGS

find_package( Boost REQUIRED COMPONENTS system filesystem program_options )
find_package( G2O REQUIRED )
find_package( SuiteSparse REQUIRED )
find_package( PCL REQUIRED )
#find_package( PCL REQUIRED COMPONENTS common io KDTree registration )

#find_package( Eigen3 3.3.3 REQUIRED) #This is gotten from PCL, so yay, otherwise there will be issues.


set( CMAKE_RUNTIME_OUTPUT_DIRECTORY    ${CMAKE_HOME_DIRECTORY}/bin )

add_definitions(
    -std=c++11
    ${PCL_DEFINITIONS}
    )

#Handles includes (via directories)
include_directories(
    ${Boost_INCLUDE_DIR} 
    ${Boost_INCLUDE_DIRS}
    ${PCL_INCLUDE_DIRS}
    ${EIGEN3_INCLUDE_DIRS}
    )

#message(
#    ${G2O_SOLVER_CSPARSE_EXTENSION} 
#)

#Handles linking (Via the libraries)
link_libraries(
    ${PCL_LIBRARIES}
    #${SuiteSparse_CHOLMOD_LIBRARY_RELEASE}
    ${SuiteSparse_LIBRARIES}
    ${G2O_CLI_LIBRARY}
    ${G2O_CORE_LIBRARY}
#    ${G2O_INCLUDE_DIR}
    ${G2O_SOLVER_CHOLMOD}
    ${G2O_SOLVER_CSPARSE}
    ${G2O_SOLVER_CSPARSE_EXTENSION}
    ${G2O_SOLVER_DENSE}
    ${G2O_SOLVER_EIGEN}
    ${G2O_SOLVER_PCG}
    ${G2O_SOLVER_SLAM2D_LINEAR}
    ${G2O_SOLVER_STRUCTURE_ONLY}
    ${G2O_STUFF_LIBRARY}
    ${G2O_TYPES_DATA}
    ${G2O_TYPES_ICP}
    ${G2O_TYPES_SBA}
    ${G2O_TYPES_SCLAM2D}
    ${G2O_TYPES_SIM3}
    ${G2O_TYPES_SLAM2D}
    ${G2O_TYPES_SLAM3D}
#    /usr/local/lib/libg2o_ext_csparse.dylib
    ${Boost_LIBRARIES}
    ${Boost_PROGRAM_OPTIONS_LIBRARY_RELEASE}
    )

#Handles linking (Via directories)
link_directories(
    ${Boost_LIBRARY_DIRS}
    ${Boost_LIBRARY_DIR}
)



add_executable(
    GraphOptimizer
    GraphOptimizer.cpp
    OptApp.cpp
    vertigo/edge_se3Switchable.cpp
    vertigo/edge_switchPrior.cpp
    vertigo/types_g2o_robust.cpp
    vertigo/vertex_switchLinear.cpp
    )

