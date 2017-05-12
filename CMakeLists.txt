cmake_minimum_required(VERSION 2.8)

project(ElasticReconstruction)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/" ${CMAKE_MODULE_PATH})

#include (FindPkgConfig)

##Optional builds n things:
option(Build_BuildCorrespondence "Build BuildCorrespondence" ON)
option(Build_FragmentOptimizer "Build FragmentOptimizer")
option(Build_GraphOptimizer "Build GraphOptimizer")
option(Build_Integrate "Build Integrate")
option(Build_GlobalRegistration "Build GlobalRegistration")

#Building B.C.
if(Build_BuildCorrespondence)
	add_subdirectory(BuildCorrespondence)
endif()

#Building FragmentOptimizer
if(Build_FragmentOptimizer)
	add_subdirectory(FragmentOptimizer)
endif()

#Building Integrate
if(Build_Integrate)
	add_subdirectory(Integrate)
endif()

#Building GraphOptimizer
if(Build_)
	add_subdirectory(GraphOptimizer)
endif()

#Building
if(Build_GlobalRegistration)
	add_subdirectory(GlobalRegistration)
endif()

#OLD STUFF (Copyed from 3d-reconstruction)
if(FALSE)

find_package( OpenCV REQUIRED )
find_package( OpenNI2 REQUIRED )
find_package( Boost REQUIRED COMPONENTS system filesystem )
find_package( glfw3 REQUIRED )
find_package( OpenGL REQUIRED )

set(
    CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${CMAKE_HOME_DIRECTORY}/bin
 )

add_definitions(
    -std=c++11
    -DCMAKE
    )

#Handles includes (via directories)
include_directories(
    ${OPENNI2_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    ${glfw3_INCLUDE_DIRS}
    ${OpenGL_INCLUDE_DIR}
    )


#Handles linking (Via the libraries)
link_libraries(
    ${OPENNI2_LIBRARY}
    ${OPENNI_LIBRARIES} 
    ${OpenCV_LIBS}
    ${Boost_LIBRARIES}
#    ${OpenGL_LIBRARIES} #opengl + glu
    ${OPENGL_gl_LIBRARY}
    glfw
    )

#Handles linking (Via directories)
link_directories(
    ${Boost_LIBRARY_DIRS}
)

add_executable(
    3D-reconstruction
    ImageSaver.cpp
    Texture.cpp
    View.cpp
    Scanner.cpp
    Utilities.cpp
    main.cpp
    )

endif()
