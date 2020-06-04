CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET(SRC main.c)

SET(CMAKE_EXPORT_COMPILE_COMMANDS on)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
# OR
# SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

# SET(INCLUDE_DIRS "/PATH/TO/INCLUDE/DIRS")
# INCLUDE_DIRECTORIES(${INCLUDE_DIRS})

FUNCTION(add_executable target_name)
# call builtin add_executable first
_add_executable(${target_name} ${ARGN})
# add custom statement
# EXECUTE_PROCESS(COMMAND ln -sf ${PROJECT_BINARY_DIR}/compile_commands.json ${PROJECT_SOURCE_DIR})
ENDFUNCTION(add_executable target_name)

ADD_EXECUTABLE(${PROJECT_NAME} ${SRC})

# SET(LIBS "libname")
# target_link_libraries(${PROJECT_NAME} ${LIBS})