cmake_minimum_required(VERSION 2.8)

#include (FindPkgConfig)


#FIND THE THINGS
find_package( Boost REQUIRED COMPONENTS system filesystem )
find_package( GLUT REQUIRED )
find_package( OpenGL REQUIRED )
find_package( PCL REQUIRED COMPONENTS common io KDTree registration point_types visualization)
#find_package( PCL REQUIRED )


set(
    CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${CMAKE_HOME_DIRECTORY}/bin
 )

add_definitions(
    -std=c++11
    ${PCL_DEFINITIONS}
    )

#Handles includes (via directories)
include_directories(
    ${Boost_INCLUDE_DIRS}
    ${glut_INCLUDE_DIRS}
    ${OpenGL_INCLUDE_DIR}
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
    BuildCorrespondence
    BuildCorrespondence.cpp
    CorresApp.cpp
    )

