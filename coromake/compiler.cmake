
if(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.2.0")
        message(FATAL_ERROR "g++ version ${CMAKE_CXX_COMPILER_VERSION} is unsupported, please upgrade to at least 10.2.0")
    endif()

    target_compile_options(${PROJECT_NAME} PUBLIC
        $<$<COMPILE_LANGUAGE:CXX>:-fcoroutines>
        $<$<COMPILE_LANGUAGE:CXX>:-fconcepts>
        $<$<COMPILE_LANGUAGE:CXX>:-fexceptions>
        $<$<COMPILE_LANGUAGE:CXX>:-Wall>
        $<$<COMPILE_LANGUAGE:CXX>:-Wextra>
        $<$<COMPILE_LANGUAGE:CXX>:-pipe>
    )
elseif(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "16.0.0")
        message(FATAL_ERROR "Clang version ${CMAKE_CXX_COMPILER_VERSION} is unsupported, please upgrade to at least 16.0.0")
    endif()

    target_compile_options(${PROJECT_NAME} PUBLIC
        $<$<COMPILE_LANGUAGE:CXX>:-fexceptions>
        $<$<COMPILE_LANGUAGE:CXX>:-Wall>
        $<$<COMPILE_LANGUAGE:CXX>:-Wextra>
        $<$<COMPILE_LANGUAGE:CXX>:-pipe>
    )
elseif(MSVC)
    target_compile_options(${PROJECT_NAME} PUBLIC
        /W4
    )
endif()

if(UNIX)
    target_link_libraries(${PROJECT_NAME} PUBLIC pthread)
endif()