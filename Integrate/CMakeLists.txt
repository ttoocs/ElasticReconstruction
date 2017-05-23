cmake_minimum_required(VERSION 2.8)

#FIND THE THINGS
find_package( Boost REQUIRED COMPONENTS system filesystem )

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
    ${Boost_INCLUDE_DIRS}
    ${PCL_INCLUDE_DIRS}
    ${EIGEN3_INCLUDE_DIRS}
    )

#Handles linking (Via the libraries)
link_libraries(
    ${Boost_LIBRARIES}
    ${PCL_LIBRARIES}
    )

#Handles linking (Via directories)
link_directories(
    ${Boost_LIBRARY_DIRS}
)

add_executable(
    Integrate
    Integrate.cpp
    ControlGrid.cpp
    IntegrateApp.cpp
    TSDFVolume.cpp
    TSDFVolumeUnit.cpp
    )

