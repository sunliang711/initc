cmake_minimum_required(VERSION 3.0)
project(<PROJECTNAME>)

set(BINARY_DIR src_bin)
set(RESULT_PATH ${PROJECT_BINARY_DIR}/bin)
set(RESULT_NAME ${PROJECT_NAME})

add_subdirectory(src ${BINARY_DIR})