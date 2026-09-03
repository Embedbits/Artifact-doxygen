set(DOXYGEN_CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
#------------------------------------------------------------------------------#
# Returns artifact version.
#
# The name of function must consist of folder name (doxygen) and postfix 
# (_GetArtifactVersion). Otherwise the buildprocess will fail.  
#
# ARTIFACT_VERSION [out]: Version of artifact in format X.Y.Z
#------------------------------------------------------------------------------#
function(doxygen_GetArtifactVersion RET_VERSION)

    # Execute the doxygen command to get its version
    execute_process(
        COMMAND doxygen --version
        OUTPUT_VARIABLE ARTIFACT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" VERSION "${ARTIFACT_VERSION}")
                    
    set(${RET_VERSION} "${VERSION}" PARENT_SCOPE)

endfunction()


#------------------------------------------------------------------------------#
# Initialize artifact for build.
#
# The name of function must consist of folder name (doxygen) and postfix 
# (_ArtifactInstall). Otherwise the buildprocess will fail.  
#
# ARTIFACT_BIN_PATH_ARG [in]: Path to the binary part of artifact
#------------------------------------------------------------------------------#
function(doxygen_ArtifactInit ARTIFACT_BIN_PATH_ARG)

    # Remove previous definition to avoid warning messages
    remove_definitions(-DDOXYGEN_STATE=OFF)
    add_definitions(-DDOXYGEN_STATE=ON)

    # Include the default Doxygen settings from the specified CMake file
    include("${DOXYGEN_CURRENT_LIST_DIR}/CMakeDoxygenDefaults.cmake")

    # Check if the host system is Windows
    if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
    
        # Update the PATH environment variable to include Doxygen and Graphviz directories
        set(ENV{PATH} "${ARTIFACT_BIN_PATH_ARG};$ENV{PATH}")
        
    else()
    
        # Update the PATH environment variable to include Doxygen and Graphviz directories
        set(ENV{PATH} "${ARTIFACT_BIN_PATH_ARG}/bin:$ENV{PATH}")
    
    endif()
    
    
    ## Set Doxygen Documentation
    # Find the Doxygen package, which is required
    find_package(Doxygen REQUIRED)
    
    # Set output directories and configuration for Doxygen
    set(DOXYGEN_INPUT_DIR       "") # Documentation generator input directories
    set(DOXYGEN_OUTPUT_DIR      "${CMAKE_BINARY_DIR}/Doxygen") # Documentation target folder
    set(DOXYGEN_CONFIG_FILE     "${CMAKE_BINARY_DIR}/Doxyfile") # Configuration doxyfile path
    set(DOXYGEN_EXCLUDE         "") # Documentation generator ignore folders
    set(DOXYGEN_TEMPLATE_CONFIG "${DOXYGEN_CURRENT_LIST_DIR}/Doxyfile.in") # Documentation template path
    
    if(NOT DEFINED MAINPAGE_MDFILE_PATH)
        
        set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${CMAKE_SOURCE_DIR}/README.md")
        set(DOXYGEN_INPUT_DIR "${DOXYGEN_INPUT_DIR} ${CMAKE_SOURCE_DIR}/README.md")
        
    else()
    
        set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${MAINPAGE_MDFILE_PATH}")
        set(DOXYGEN_INPUT_DIR "${DOXYGEN_INPUT_DIR} ${MAINPAGE_MDFILE_PATH}")
        
    endif()

endfunction()

#------------------------------------------------------------------------------#
# Starts doxygen generation.
#------------------------------------------------------------------------------#
function(Doxygen_Generate)

    # Check if Doxygen is found
    if(DOXYGEN_FOUND)
    
        # Get the input and exclude directories for Doxygen
        get_property(DOXYGEN_INPUT_DIR GLOBAL PROPERTY DOXYGEN_INPUT_DIR)
        get_property(DOXYGEN_EXCLUDE GLOBAL PROPERTY DOXYGEN_EXCLUDE)
        get_property(DOXYGEN_USE_MDFILE_AS_MAINPAGE GLOBAL PROPERTY DOXYGEN_USE_MDFILE_AS_MAINPAGE)
    
        # Add project README.md file as main page
#        set(DOXYGEN_INPUT_DIR "${DOXYGEN_INPUT_DIR} ${CMAKE_SOURCE_DIR}/README.md")

        # Replace semicolons with spaces for Doxygen compatibility
        string(REPLACE ";" " " DOXYGEN_FILE_PATTERNS "${DOXYGEN_FILE_PATTERNS}")
        string(REPLACE ";" " " DOXYGEN_INPUT_DIR "${DOXYGEN_INPUT_DIR}")

        # Print Doxygen configuration details if verbose mode is enabled
        if(CMAKE_VERBOSE_MAKEFILE)
            message("Doxygen input directories: ${DOXYGEN_INPUT_DIR}")
            message("Doxygen exclude directories: ${DOXYGEN_EXCLUDE}")
            message("Doxygen file patterns: ${DOXYGEN_FILE_PATTERNS}")
            message("Doxygen output directory: ${DOXYGEN_OUTPUT_DIR}")
            message("Doxygen config file: ${DOXYGEN_CONFIG_FILE}")
            message("Doxygen template config: ${DOXYGEN_TEMPLATE_CONFIG}")
        endif()

        # Generate the Doxyfile from the template
        configure_file(
            ${DOXYGEN_TEMPLATE_CONFIG}
            ${DOXYGEN_CONFIG_FILE}
            @ONLY
        )

        # Add a custom target to generate the documentation
        add_custom_target(Doxygen
            COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_CONFIG_FILE}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Generating Doxygen documentation"
            VERBATIM
        )
    else()
        # Print a message if Doxygen is not found
        message("Doxygen is required but was not found.")
    endif()

endfunction()

#------------------------------------------------------------------------------#
# Adds path for doxygen generation.
#
# Function adds a path to the Doxygen input directories. This is necessary for
# all files user wants to have in output file.
#------------------------------------------------------------------------------#
function(Doxygen_AddPath DOXY_FILE_PATH_ARG)

    # Get the current Doxygen input directories
    get_property(DOXYGEN_INPUT_DIR GLOBAL PROPERTY DOXYGEN_INPUT_DIR)
    # Add the new path to the input directories
    set(DOXYGEN_INPUT_DIR "${DOXYGEN_INPUT_DIR} ${DOXY_FILE_PATH_ARG}" CACHE INTERNAL "Doxygen input directories")

    # Print the added path if verbose mode is enabled
    if(CMAKE_VERBOSE_MAKEFILE)
        message("Added Doxygen input directories: ${DOXY_FILE_PATH_ARG}")
    endif()

endfunction()

#------------------------------------------------------------------------------#
# Adds path for doxygen ignore list.
#
# Function adds a path to the Doxygen ignore directories. The user can exclude 
# specific directories and its subdirectories from doxygen documentation 
# generation.
#------------------------------------------------------------------------------#
function(Doxygen_AddIgnorePath DOXY_FILE_PATH_ARG)

    # Get the current Doxygen exclude directories
    get_property(DOXYGEN_EXCLUDE GLOBAL PROPERTY DOXYGEN_EXCLUDE)
    # Add the new path to the exclude directories
    set(DOXYGEN_EXCLUDE "${DOXYGEN_EXCLUDE} ${DOXY_FILE_PATH_ARG}" CACHE INTERNAL "Doxygen exclude directories")

    # Print the added path if verbose mode is enabled
    if(CMAKE_VERBOSE_MAKEFILE)
        message("Added Doxygen exclude directories: ${DOXY_FILE_PATH_ARG}")
    endif()

endfunction()
