SET(SRC main.c)

SET(EXECUTABLE_OUTPUT_PATH ${RESULT_PATH})

# set include dirs
# for example: SET(include_dirs inc1 inc2 inc3)
SET(include_dirs)

# set sub directory
# for example: SET(sub_dirs s1 s2 s3)
SET(sub_dirs)

# set libs used in the following list 'LIBS'
# for example: SET(LIBS a b c)
SET(LIBS)

# set link_directories
SET(link_dirs)

SET(CMAKE_EXPORT_COMPILE_COMMANDS on)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
# OR
# SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

FOREACH(inc ${include_dirs})
    MESSAGE(STATUS "Add include dir: ${inc}")
    INCLUDE_DIRECTORIES(${inc})
ENDFOREACH()

FOREACH(sub ${sub_dirs})
    MESSAGE(STATUS "add_subdirectory ${sub}")
    ADD_SUBDIRECTORY(${sub} ${sub}_bin)
ENDFOREACH()

FOREACH(dir ${link_dirs})
    MESSAGE(STATUS "link_directories ${link}")
    LINK_DIRECTORIES(${dir})
ENDFOREACH()

FUNCTION(add_executable target_name)
    # call builtin add_executable first
    _add_executable(${target_name} ${ARGN})
    # add custom statement
    EXECUTE_PROCESS(COMMAND ln -sf ${PROJECT_BINARY_DIR}/compile_commands.json ${PROJECT_SOURCE_DIR})
ENDFUNCTION(add_executable target_name)

ADD_EXECUTABLE(${RESULT_NAME} ${SRC})

IF(LIBS)
    target_link_libraries(${PROJECT_NAME} ${LIBS})
ENDIF()

ADD_CUSTOM_TARGET(
    run 
    COMMAND ${EXECUTABLE_OUTPUT_PATH}/${RESULT_NAME}
    DEPENDS ${PROJECT_NAME}
)
