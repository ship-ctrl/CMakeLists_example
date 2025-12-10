set(AV_VERSION "0.1.0")

# Simple build success handler
#string(TIMESTAMP NOW)

# Include the module
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(AutoVersion.cmake)

increment_and_save_min_ver()
