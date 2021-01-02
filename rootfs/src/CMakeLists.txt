CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET(SRC main.c)

#set include dirs
# for example: SET(include_dirs inc1 inc2 inc3)
SET(include_dirs)

#set sub directory
# for example: SET(sub_dirs s1 s2 s3)
SET(sub_dirs)

#set libs used in the following list 'LIBS'
# for example: SET(LIBS a b c)
SET(LIBS)

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
# SET(INCLUDE_DIRS "/PATH/TO/INCLUDE/DIRS")
# INCLUDE_DIRECTORIES(${INCLUDE_DIRS})

FUNCTION(add_executable target_name)
    # call builtin add_executable first
    _add_executable(${target_name} ${ARGN})
    # add custom statement
    EXECUTE_PROCESS(COMMAND ln -sf ${PROJECT_BINARY_DIR}/compile_commands.json ${PROJECT_SOURCE_DIR})
ENDFUNCTION(add_executable target_name)

ADD_EXECUTABLE(${PROJECT_NAME} ${SRC})

IF(LIBS)
    target_link_libraries(${PROJECT_NAME} ${LIBS})
ENDIF()

ADD_CUSTOM_TARGET(
    run 
    COMMAND ${PROJECT_BINARY_DIR}/${BINARY_DIR}/${PROJECT_NAME}
    DEPENDS ${PROJECT_NAME}
)