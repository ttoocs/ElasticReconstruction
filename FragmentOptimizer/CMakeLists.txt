cmake_minimum_required(VERSION 2.8)

#include (FindPkgConfig)


#FIND THE THINGS
find_package( Boost REQUIRED COMPONENTS system filesystem )
#find_package( GLUT REQUIRED )
#find_package( OpenGL REQUIRED )
find_package( EIGEN3 3.3.3 REQUIRED )
find_package( PCL REQUIRED COMPONENETS common )
#find_package( PCL REQUIRED COMPONENTS common io KDTree registration point_types visualization)
#find_package( PCL REQUIRED )


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY  ${CMAKE_HOME_DIRECTORY}/bin )

#Attempt to use the provided Eigen version
#set(EXTERNAL_EIGEN ${CMAKE_CURRENT_SOURCE_DIR}/external)

add_definitions(
    -std=c++11
    ${PCL_DEFINITIONS}
    -DNEWEIGEN            #Disable the included eigenVersion
    )

#Handles includes (via directories)
include_directories(
    ${Boost_INCLUDE_DIRS}
    ${glut_INCLUDE_DIRS}
    ${OpenGL_INCLUDE_DIR}
    ${EIGEN_INCLUDE_DIRS}    
#    ${EXTERNAL_EIGEN}
    ${PCL_INCLUDE_DIRS}
)


#Handles linking (Via the libraries)
link_libraries(
    ${Boost_LIBRARIES}
    ${OPENGL_gl_LIBRARY}
    ${GLUT_LIBRARY}
    ${PCL_LIBRARIES}
    )

#Handles linking (Via directories)
link_directories(
    ${Boost_LIBRARY_DIRS}
)

add_executable(
    FragmentOptimizer
    FragmentOptimizer.cpp
    HashSparseMatrix.cpp
    OptApp.cpp
    PointCloud.cpp
    )

