set(SRC main.cpp)

set(EXECUTABLE_OUTPUT_PATH ${RESULT_PATH})

# set include dirs
# for example: set(include_dirs inc1 inc2 inc3)
set(include_dirs)

# set sub directory
# for example: SET(sub_dirs s1 s2 s3)
set(sub_dirs)

# set libs used in the following list 'LIBS'
# for example: set(LIBS a b c)
set(LIBS)

# set link_directories
set(link_dirs)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
# OR
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

foreach(inc ${include_dirs})
    message(STATUS "Add include dir: ${inc}")
    include_directories(${inc})
endforeach()

foreach(sub ${sub_dirs})
    message(STATUS "add_subdirectory ${sub}")
    add_subdirectory(${sub} ${sub}_bin)
endforeach()

foreach(dir ${link_dirs})
    message(STATUS "link_directories ${link}")
    link_directories(${dir})
endforeach()

function(add_executable target_name)
    # call builtin add_executable first
    _add_executable(${target_name} ${ARGN})
    # add custom statement
    execute_process(COMMAND ln -sf ${PROJECT_BINARY_DIR}/compile_commands.json ${PROJECT_SOURCE_DIR})
endfunction(add_executable target_name)

add_executable(${RESULT_NAME} ${SRC})

if(LIBS)
    target_link_libraries(${PROJECT_NAME} ${LIBS})
endif()

add_custom_target(
    run 
    COMMAND ${EXECUTABLE_OUTPUT_PATH}/${RESULT_NAME}
    DEPENDS ${PROJECT_NAME}
)
