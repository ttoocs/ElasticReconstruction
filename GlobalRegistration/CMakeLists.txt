cmake_minimum_required(VERSION 2.8)

#FIND THE THINGS
find_package( Boost REQUIRED COMPONENTS system filesystem )

find_package( PCL REQUIRED COMPONENTS common io KDTree registration search)
#find_package( PCL REQUIRED)

#find_package( Eigen3 3.3.3 REQUIRED) #This is gotten from PCL, so yay, otherwise there will be issues.

find_package(OpenMP)
if (OPENMP_FOUND)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

set( CMAKE_RUNTIME_OUTPUT_DIRECTORY    ${CMAKE_HOME_DIRECTORY}/bin )

add_definitions(
    -std=c++11
    -O3
    ${PCL_DEFINITIONS}
    )

add_executable(
    GlobalRegistration
    GlobalRegistration.cpp
    RansacCurvature.cpp
    )

#Handles includes (via directories)
include_directories(
    ${Boost_INCLUDE_DIRS}
    ${PCL_INCLUDE_DIRS}
    ${EIGEN3_INCLUDE_DIRS}
    )

#Handles linking (Via the libraries)
target_link_libraries(
    GlobalRegistration
    ${Boost_LIBRARIES}
    ${PCL_LIBRARIES}
    )

#Handles linking (Via directories)
link_directories(
    ${Boost_LIBRARY_DIRS}
)


