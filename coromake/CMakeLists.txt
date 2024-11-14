cmake_minimum_required(VERSION 3.15)
include(CMakeDependentOption)
include(FetchContent)

project(libcoro
    VERSION 0.11.1
    LANGUAGES CXX
    DESCRIPTION "C++20 coroutine library"
)



add_library(${PROJECT_NAME})
set_target_properties(${PROJECT_NAME} PROPERTIES 
												LINKER_LANGUAGE CXX 
												PREFIX 			"" 
												VERSION			${PROJECT_VERSION} 
												SOVERSION		${PROJECT_VERSION_MAJOR}
												OUTPUT_NAME 	${PROJECT_NAME}
                                                DEBUG_POSTFIX 	"_d")
													
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_20)

include(platform.cmake)
include(compiler.cmake)

#if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
#    set(MACOSX TRUE)
#    # We need to build with clang >= 17, assuming its installed by
#    # brew. We also need to force linking to libc++.a
#    add_link_options(-L/usr/local/opt/llvm/lib)
#    link_libraries(-lc++)
#endif()

include(GNUInstallDirs)
include(GenerateExportHeader)
message(STATUS "COROLIB_SOURCE_ROOT_DIR: ${COROLIB_SOURCE_ROOT_DIR}")
message(STATUS "c-ares_DIR: ${c-ares_DIR}")

if (NOT "$ENV{version}" STREQUAL "")
    set(PROJECT_VERSION "$ENV{version}" CACHE INTERNAL "Copied from environment variable")
endif()


set(BUILD_SHARED_LIBS ${LIBCORO_BUILD_SHARED_LIBS} CACHE INTERNAL "")
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ${LIBCORO_BUILD_SHARED_LIBS} CACHE INTERNAL "")

if(NOT DEFINED COROLIB_SOURCE_ROOT_DIR OR "${COROLIB_SOURCE_ROOT_DIR}" STREQUAL "")
	message(FATAL_ERROR "COROLIB_SOURCE_ROOT_DIR not defined or empty")
endif()

set(CORO_INC ${COROLIB_SOURCE_ROOT_DIR}/include/coro)
set(CORO_SRC ${COROLIB_SOURCE_ROOT_DIR}/src)

message(STATUS "CORO_SRC ${CORO_SRC}")
message(STATUS "CORO_INC ${CORO_INC}")
message(STATUS "$CORO_INC/mutex.hpp ${CORO_INC}/mutex.hpp")

set(LIBCORO_SOURCE_FILES)

# Core concepts and traits
set(LIBCORO_CORE_CONCEPTS_FILES
										${CORO_INC}/concepts/awaitable.hpp
										${CORO_INC}/concepts/buffer.hpp
										${CORO_INC}/concepts/executor.hpp
										${CORO_INC}/concepts/promise.hpp
										${CORO_INC}/concepts/range_of.hpp)

# Utils
set(LIBCORO_CORE_UTILS_FILES
										${CORO_INC}/attribute.hpp
										${CORO_INC}/time.hpp
										${CORO_INC}/ring_buffer.hpp
										${CORO_INC}/detail/void_value.hpp)

# Coroutine foundation
set(LIBCORO_CORE_FOUNDATION_FILES
										${CORO_INC}/coro.hpp
										${CORO_INC}/task.hpp
										${CORO_INC}/generator.hpp
										${CORO_INC}/task_container.hpp)

# Core synchronization primitives
set(LIBCORO_CORE_SYNC_PRIMITIVES_FILES
										${CORO_INC}/mutex.hpp               ${CORO_SRC}/mutex.cpp
										${CORO_INC}/semaphore.hpp           ${CORO_SRC}/semaphore.cpp
										${CORO_INC}/shared_mutex.hpp)

# Coordination mechanisms
set(LIBCORO_CORE_SYNC_COORDINATION_FILES
										${CORO_INC}/event.hpp               ${CORO_SRC}/event.cpp
										${CORO_INC}/latch.hpp
										${CORO_INC}/sync_wait.hpp           ${CORO_SRC}/sync_wait.cpp
										${CORO_INC}/when_all.hpp)

# Threading and execution
set(LIBCORO_CORE_EXECUTION_FILES
										${CORO_INC}/thread_pool.hpp         ${CORO_SRC}/thread_pool.cpp)

# Aggregate all core components
set(LIBCORO_CORE_SOURCE_FILES
										${LIBCORO_CORE_CONCEPTS_FILES}
										${LIBCORO_CORE_UTILS_FILES}
										${LIBCORO_CORE_FOUNDATION_FILES}
										${LIBCORO_CORE_SYNC_PRIMITIVES_FILES}
										${LIBCORO_CORE_SYNC_COORDINATION_FILES}
										${LIBCORO_CORE_EXECUTION_FILES})
										
										
										
										
list(APPEND LIBCORO_SOURCE_FILES ${LIBCORO_CORE_SOURCE_FILES})
								

set(NET_INC ${CORO_INC}/net)
set(NET_SRC ${CORO_SRC}/net)

# Network Core
set(LIBCORO_NETWORK_CORE_FILES
										${NET_INC}/ip_address.hpp        ${NET_SRC}/ip_address.cpp
										${NET_INC}/hostname.hpp
										${NET_INC}/connect.hpp           ${NET_SRC}/connect.cpp)
										
# IO Foundation
set(LIBCORO_NETWORK_IO_FILES
										${CORO_INC}/detail/poll_info.hpp
										${CORO_INC}/fd.hpp
										${CORO_INC}/io_scheduler.hpp     ${CORO_SRC}/io_scheduler.cpp
										${CORO_INC}/poll.hpp             ${CORO_SRC}/poll.cpp)


										
# Network Status
set(LIBCORO_NETWORK_STATUS_FILES
										${NET_INC}/recv_status.hpp       ${NET_SRC}/recv_status.cpp
										${NET_INC}/send_status.hpp       ${NET_SRC}/send_status.cpp)
# Protocol Implementations
set(LIBCORO_NETWORK_PROTOCOLS_FILES
										# TCP
										${NET_INC}/tcp/client.hpp        ${NET_SRC}/tcp/client.cpp
										${NET_INC}/tcp/server.hpp        ${NET_SRC}/tcp/server.cpp
										# UDP
										${NET_INC}/udp/peer.hpp         ${NET_SRC}/udp/peer.cpp
										# Socket base
										${NET_INC}/socket.hpp            ${NET_SRC}/socket.cpp)
 # DNS
set(LIBCORO_NETWORK_DNS_FILES
										${NET_INC}/dns/resolver.hpp      ${NET_SRC}/dns/resolver.cpp)

										
set(LIBCORO_NETWORK_SOURCE_FILES 
										${LIBCORO_NETWORK_CORE_FILES}
										${LIBCORO_NETWORK_IO_FILES}
										${LIBCORO_NETWORK_STATUS_FILES}
										${LIBCORO_NETWORK_PROTOCOLS_FILES}
										${LIBCORO_NETWORK_DNS_FILES})


set(TLS_INC ${NET_INC}/tls)
set(TLS_SRC ${NET_SRC}/tls)

# TLS Core
set(LIBCORO_NETWORK_TLS_CORE_FILES
										${TLS_INC}/context.hpp        ${TLS_SRC}/context.cpp)

# TLS Sockets
set(LIBCORO_NETWORK_TLS_SOCKETS_FILES
										${TLS_INC}/client.hpp         ${TLS_SRC}/client.cpp
										${TLS_INC}/server.hpp         ${TLS_SRC}/server.cpp)

# TLS Status
set(LIBCORO_NETWORK_TLS_STATUS_FILES
										${TLS_INC}/connection_status.hpp ${TLS_SRC}/connection_status.cpp
										${TLS_INC}/recv_status.hpp    	 ${TLS_SRC}/recv_status.cpp
										${TLS_INC}/send_status.hpp    	 ${TLS_SRC}/send_status.cpp)

set(LIBCORO_NETWORK_TLS_SOURCE_FILES
										${LIBCORO_NETWORK_TLS_CORE_FILES}
										${LIBCORO_NETWORK_TLS_SOCKETS_FILES}
										${LIBCORO_NETWORK_TLS_STATUS_FILES}	)


if(LIBCORO_FEATURE_NETWORKING)	

    find_package(c-ares CONFIG REQUIRED)
	target_link_libraries(${PROJECT_NAME} PUBLIC c-ares::cares)
    target_compile_definitions(${PROJECT_NAME} PUBLIC LIBCORO_FEATURE_NETWORKING)

	list(APPEND LIBCORO_SOURCE_FILES ${LIBCORO_NETWORK_SOURCE_FILES})

    if(LIBCORO_FEATURE_TLS)
        find_package(OpenSSL REQUIRED)
		list(APPEND LIBCORO_SOURCE_FILES ${LIBCORO_NETWORK_TLS_SOURCE_FILES})
        target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::SSL OpenSSL::Crypto)
        target_compile_definitions(${PROJECT_NAME} PUBLIC LIBCORO_FEATURE_TLS)

    endif()
endif()


set(${PROJECT_NAME}_GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/Generated)

set(${PROJECT_NAME}_EXPORT_HEADER ${${PROJECT_NAME}_GENERATED_DIR}/include/coro/export.hpp)
generate_export_header(${PROJECT_NAME} 
							EXPORT_FILE_NAME 
								${${PROJECT_NAME}_EXPORT_HEADER}								
							BASE_NAME
								CORO
								)


target_sources(${PROJECT_NAME} PRIVATE ${LIBCORO_SOURCE_FILES})
target_include_directories(${PROJECT_NAME} PUBLIC 
												$<INSTALL_INTERFACE:include> 
												$<BUILD_INTERFACE:${COROLIB_SOURCE_ROOT_DIR}/include>
												$<BUILD_INTERFACE:${${PROJECT_NAME}_GENERATED_DIR}/include>
												)

if(UNIX)
    target_link_libraries(${PROJECT_NAME} PUBLIC pthread)
endif()


if(LIBCORO_CODE_COVERAGE)
	target_compile_options(${PROJECT_NAME} PRIVATE --coverage)
	target_link_libraries(${PROJECT_NAME} PRIVATE gcov)
endif()

   



# generate pc file for pkg-config
if(MSVC)
    set(target1 ${PROJECT_NAME})
else()
    string(REGEX REPLACE "^lib" "" target1 ${PROJECT_NAME})
endif()
configure_file(libcoro.pc.in ${${PROJECT_NAME}_GENERATED_DIR}/libcoro.pc @ONLY)


include(GNUInstallDirs)  # Include GNUInstallDirs for standard installation directories
# Install the library target
install(TARGETS ${PROJECT_NAME}
		EXPORT 	${PROJECT_NAME}-targets
		RUNTIME DESTINATION 
			${CMAKE_INSTALL_BINDIR}         
		LIBRARY DESTINATION 
			${CMAKE_INSTALL_LIBDIR}         
		ARCHIVE DESTINATION 
			${CMAKE_INSTALL_LIBDIR}         
		INCLUDES DESTINATION 
			${CMAKE_INSTALL_INCLUDEDIR}    
)

# Install header files
install(DIRECTORY 
			${COROLIB_SOURCE_ROOT_DIR}/include/coro/
		DESTINATION 
			${CMAKE_INSTALL_INCLUDEDIR}/coro
)

install(FILES 
			${${PROJECT_NAME}_EXPORT_HEADER}
		DESTINATION 
			${CMAKE_INSTALL_INCLUDEDIR}/coro
)

# Install the pkg-config file
install(FILES ${${PROJECT_NAME}_GENERATED_DIR}/libcoro.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

export(EXPORT ${PROJECT_NAME}-targets
       FILE 
            ${${PROJECT_NAME}_GENERATED_DIR}/cmake/${PROJECT_NAME}Targets.cmake
       NAMESPACE
            ${PROJECT_NAME}::
)

install(EXPORT ${PROJECT_NAME}-targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake

)



# Generate and install CMake configuration files
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${${PROJECT_NAME}_GENERATED_DIR}/cmake/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION 
		${PROJECT_VERSION}
    COMPATIBILITY 
		AnyNewerVersion
)

configure_file(
    "Config.cmake.in"
    "${${PROJECT_NAME}_GENERATED_DIR}/cmake/${PROJECT_NAME}Config.cmake"
    @ONLY
)

install(FILES
    "${${PROJECT_NAME}_GENERATED_DIR}/cmake/${PROJECT_NAME}Config.cmake"
	"${${PROJECT_NAME}_GENERATED_DIR}/cmake/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake
)

