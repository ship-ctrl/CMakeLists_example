cmake_minimum_required(VERSION 3.16) # feel free to downgrade on build errors but it's better be 3.22
project(GenericProject VERSION 0.01.001)

# Include the module
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(AutoVersion)
#include(FetchContent)

# Set the C++ standard to be used
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-Wall -g -O0")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-Wall -O3 -flto")

set(VERSION_FILE "${CMAKE_SOURCE_DIR}/version_info.txt")

# Increment build number each time CMake runs
increment_and_save_build(${CMAKE_SOURCE_DIR})

# Read back the updated values for use in CMake
read_version_from_file(${CMAKE_SOURCE_DIR})

option(INCLUDE_GLOG "fetch glog and link to main target" OFF)

if(INCLUDE_GLOG)
    #FetchContent_Declare( 
    #glog
    #GIT_REPOSITORY https://github.com/google/glog.git
    #GIT_TAG        v0.6.0  # You can change to specific version
    #)
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/glog/CMakeLists.txt)
        message(STATUS "Updating glog submodule...")
        execute_process(
            COMMAND git submodule update --init --recursive glog
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_RESULT
        )
    else()
        message(STATUS "Initializing glog submodule...")
        execute_process(
            COMMAND git submodule add https://github.com/google/glog.git
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_RESULT
        )
        #FetchContent_Declare( glog  GIT_REPOSITORY https://github.com/google/glog.git )
    endif(EXISTS "${PROJECT_SOURCE_DIR}/glog")
    
    if(NOT GIT_RESULT EQUAL 0)
        message(WARNING "Failed to initialize glog submodule. You may need to run: git submodule update --init --recursive")
    endif()
    execute_process(
            COMMAND cmake -S glog -B glog/build && cd glog && sudo make install
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE CM_RESULT
    )
    if(NOT CM_RESULT EQUAL 0)
        message(WARNING "Failed to install glog submodule. You may need to run: cmake -S glog -B glog/build && cd glog && sudo make install")
    endif()
    # Set glog options before fetching
    #set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries")
    #set(WITH_GFLAGS OFF CACHE BOOL "Build with gflags")  # Set to ON if you need gflags
    #set(WITH_UNWIND OFF CACHE BOOL "Build with unwind support")
    #FetchContent_MakeAvailable(glog)
    find_package(glog REQUIRED)
endif(INCLUDE_GLOG)


option(INCLUDE_GFLAGS "fetch gflags and link to main target" OFF)

if(INCLUDE_GFLAGS)
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/gflags/CMakeLists.txt)
        message(STATUS "Updating gflags submodule...")
        execute_process(
            COMMAND git submodule update --init --recursive gflags
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_RESULT
        )
    else()
        message(STATUS "Initializing gflags submodule...")
        execute_process(
            COMMAND git submodule add https://github.com/gflags/gflags.git
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_RESULT
        )
        #FetchContent_Declare( gflags  GIT_REPOSITORY https://github.com/gflags/gflags.git )
    endif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/gflags/CMakeLists.txt)
    
    if(NOT GIT_RESULT EQUAL 0)
        message(WARNING "Failed to initialize gflags submodule. You may need to run: git submodule update --init --recursive")
    endif()
    execute_process(
            COMMAND cmake -S gflags -B gflags/build && cd gflags && sudo make install
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE CM_RESULT
    )
    if(NOT CM_RESULT EQUAL 0)
        message(WARNING "Failed to install gflags submodule. You may need to run: cmake -S gflags -B gflags/build && cd gflags && sudo make install")
    endif()
    
    #FetchContent_MakeAvailable(gflags)
    find_package(gflags REQUIRED)
endif(INCLUDE_GFLAGS)

configure_file( 
    ${CMAKE_SOURCE_DIR}/Version.h.in 
    ${CMAKE_SOURCE_DIR}/Version.h
    )

#find_package(Threads REQUIRED)
if(BUILD_TESTING)
    find_package( Boost 1.7 COMPONENTS system REQUIRED CONFIG)
    enable_testing()
    add_subdirectory(test)
    if(Boost_FOUND)
        message ("Boost found")
    else()
        message (FATAL_ERROR "Cannot find Boost")
    endif(Boost_FOUND)
endif(BUILD_TESTING)

message(STATUS "==========================================")
message(STATUS "Project: ${PROJECT_NAME}")
message(STATUS "Version: ${FULL_VERSION}")
message(STATUS "Build Number: ${BUILD_NUMBER}")
message(STATUS "Minor Version: ${MINOR_VERSION}")
message(STATUS "==========================================")

## find_package(catkin REQUIRED COMPONENTS
##  roscpp
##  std_msgs
##  hydro_msgs
##  realtime_tools
## )

include_directories(
  #${catkin_INCLUDE_DIRS}
  ${Boost_INCLUDE_DIR}
  /usr/include
  #/usr/include/modbus
)
if(Enable_Licensing)
    add_subdirectory(Silencer_CLASS) # make it git and auto downloadble
    list(APPEND licLib "silencer")
endif(Enable_Licensing)

#list(APPEND EXTRA_INCLUDES "/usr/include/modbus/modbus.h")

#list(APPEND Mbus_INCLUDES "ModbusRTU.hpp")
#list(APPEND Mbus_INCLUDES "Pump.hpp")
#list(APPEND Mbus_INCLUDES "ModbusSlave.hpp")
#list(APPEND Mbus_INCLUDES "alphafilter.hpp")

if(NOT TESTONLY)
    add_executable(example src/main.cxx ${Mbus_INCLUDES} ${YAML_CPP_LIBRARIES} ${EXTRA_INCLUDES})
    target_link_libraries(example 
    glog::glog 
    #PRIVATE libmodbus.so 
    ${licLib} 
    ${catkin_LIBRARIES})
    
    # Add post-build command to the target
    add_custom_command(TARGET example POST_BUILD
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/IncreaseMinor.cmake
        COMMENT "Updating build information..."
        VERBATIM
    )
endif(NOT TESTONLY)


