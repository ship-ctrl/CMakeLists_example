cmake_minimum_required(VERSION 3.16) # feel free to downgrade on build errors but it's better be 3.22
project(GenericModbusNODE VERSION 0.01.001)

# Include the module
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(AutoVersion)

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
    if(EXISTS "${PROJECT_SOURCE_DIR}/glog")
        add_subdirectory(glog)
    endif(EXISTS "${PROJECT_SOURCE_DIR}/glog")
    
    #FetchContent_Declare( gflags  GIT_REPOSITORY https://github.com/gflags/gflags.git )
    #FetchContent_Declare( glog  GIT_REPOSITORY https://github.com/google/glog.git )

endif(INCLUDE_GLOG)


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
    #add_executable(TARGETNAME src/src.cxx ${Mbus_INCLUDES} ${YAML_CPP_LIBRARIES} ${EXTRA_INCLUDES})
    #target_link_libraries(TARGETNAME PRIVATE libmodbus.so ${licLib} ${catkin_LIBRARIES})
    
    # Add post-build command to the target
    add_custom_command(TARGET TARGETNAME POST_BUILD
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/IncreaseMinor.cmake
        COMMENT "Updating build information..."
        VERBATIM
    )
endif(NOT TESTONLY)


