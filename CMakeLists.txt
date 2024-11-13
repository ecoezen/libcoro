cmake_minimum_required(VERSION 3.15)

include(ExternalProject)
include(CMakeDependentOption)

project(libcoro-superbuild
    VERSION 0.11.1
    LANGUAGES C CXX
    DESCRIPTION "C++20 coroutine library"
)



option(LIBCORO_BUILD_TESTS           "Build the tests, Default=ON." ON)
option(LIBCORO_CODE_COVERAGE         "Enable code coverage, tests must also be enabled, Default=OFF" OFF)
option(LIBCORO_BUILD_EXAMPLES        "Build the examples, Default=ON." ON)
option(LIBCORO_RUN_GITCONFIG         "Set the githooks directory to auto format and update the readme, Default=OFF." OFF)
option(LIBCORO_BUILD_SHARED_LIBS     "Build shared libraries, Default=OFF." OFF)

# Set the githooks directory to auto format and update the readme.
if (LIBCORO_RUN_GITCONFIG)
    message("${PROJECT_NAME} ${CMAKE_CURRENT_SOURCE_DIR} -> git config --local core.hooksPath .githooks")
    execute_process(
        COMMAND git config --local core.hooksPath .githooks
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()

cmake_dependent_option(LIBCORO_FEATURE_NETWORKING "Include networking features, Default=ON." ON "NOT EMSCRIPTEN; NOT MSVC" OFF)
cmake_dependent_option(LIBCORO_FEATURE_TLS "Include TLS encryption features, Default=ON." ON "NOT EMSCRIPTEN; NOT MSVC" OFF)

message("${PROJECT_NAME} LIBCORO_EXTERNAL_DEPENDENCIES = ${LIBCORO_EXTERNAL_DEPENDENCIES}")
message("${PROJECT_NAME} LIBCORO_BUILD_TESTS           = ${LIBCORO_BUILD_TESTS}")
message("${PROJECT_NAME} LIBCORO_CODE_COVERAGE         = ${LIBCORO_CODE_COVERAGE}")
message("${PROJECT_NAME} LIBCORO_BUILD_EXAMPLES        = ${LIBCORO_BUILD_EXAMPLES}")
message("${PROJECT_NAME} LIBCORO_FEATURE_NETWORKING    = ${LIBCORO_FEATURE_NETWORKING}")
message("${PROJECT_NAME} LIBCORO_FEATURE_TLS           = ${LIBCORO_FEATURE_TLS}")
message("${PROJECT_NAME} LIBCORO_RUN_GITCONFIG         = ${LIBCORO_RUN_GITCONFIG}")
message("${PROJECT_NAME} LIBCORO_BUILD_SHARED_LIBS     = ${LIBCORO_BUILD_SHARED_LIBS}")


if(LIBCORO_FEATURE_NETWORKING)

ExternalProject_Add(c-ares
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/c-ares
    GIT_REPOSITORY "https://github.com/c-ares/c-ares.git"
    GIT_TAG "main"
	GIT_SHALLOW TRUE
    CMAKE_ARGS
        -DCARES_SHARED:BOOL=$<IF:$<BOOL:${LIBCORO_BUILD_SHARED_LIBS}>,ON,OFF>
        -DCARES_STATIC:BOOL=$<IF:$<BOOL:${LIBCORO_BUILD_SHARED_LIBS}>,OFF,ON>
        -DCARES_STATIC_PIC:BOOL=$<IF:$<BOOL:${LIBCORO_BUILD_SHARED_LIBS}>,ON,OFF>
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/c-ares

    BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target all --config ${CMAKE_BUILD_TYPE} 
    INSTALL_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target install --config ${CMAKE_BUILD_TYPE} 
	STEP_TARGETS download configure build install
    UPDATE_COMMAND ""

    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
	LOG_OUTPUT_ON_FAILURE TRUE
)

endif()

# if OPENSSL_ROOT_DIR is set, propagate that hint path to the external projects with OpenSSL dependency.https://github.com/c-ares/c-ares.git
set(_CMAKE_ARGS_OPENSSL_ROOT_DIR "")
if (OPENSSL_ROOT_DIR)
  set(_CMAKE_ARGS_OPENSSL_ROOT_DIR "-DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}")
endif()

ExternalProject_Add(libcoro
  PREFIX libcoro
  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/coromake"
  BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/libcoro"
  INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install --config $<CONFIG>
  CMAKE_CACHE_ARGS
  		-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
		-DLIBCORO_BUILD_SHARED_LIBS:BOOL=$<IF:$<BOOL:${LIBCORO_BUILD_SHARED_LIBS}>,ON,OFF>
		-DCOROLIB_SOURCE_ROOT_DIR:STRING=${CMAKE_CURRENT_SOURCE_DIR}
		-DLIBCORO_FEATURE_NETWORKING:BOOL=$<IF:$<BOOL:${LIBCORO_FEATURE_NETWORKING}>,ON,OFF>
        -Dc-ares_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/c-ares/lib/cmake/c-ares
        ${_CMAKE_ARGS_OPENSSL_ROOT_DIR}
		
  #DEPENDS $<IF:$<BOOL:${LIBCORO_FEATURE_NETWORKING}>,c-ares>

)

ExternalProject_Add(libcoro_test
  PREFIX libcoro_test
  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/test"
  BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/libcoro_test"
  INSTALL_COMMAND ""
  CMAKE_CACHE_ARGS
			-Dlibcoro_DIR:PATH=${CMAKE_INSTALL_PREFIX}/../libcoro/lib/cmake
			-DLIBCORO_FEATURE_NETWORKING:BOOL=$<IF:$<BOOL:${LIBCORO_FEATURE_NETWORKING}>,ON,OFF>		
  DEPENDS libcoro
)

message(STATUS "${CMAKE_INSTALL_PREFIX}/lib/cmake ----")

ExternalProject_Add(libcoro_examples
  PREFIX libcoro_examples
  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/examples"
  BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/libcoro_examples"
  INSTALL_COMMAND ""
  CMAKE_CACHE_ARGS
			-Dlibcoro_DIR:PATH=${CMAKE_INSTALL_PREFIX}/../libcoro/lib/cmake
			-DLIBCORO_FEATURE_NETWORKING:BOOL=$<IF:$<BOOL:${LIBCORO_FEATURE_NETWORKING}>,ON,OFF>

		
  DEPENDS libcoro

)


