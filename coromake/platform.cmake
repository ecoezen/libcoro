if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(MACOSX TRUE)
    # We need to build with clang >= 17, assuming its installed by
    # brew. We also need to force linking to libc++.a
    add_link_options(-L/usr/local/opt/llvm/lib)
    link_libraries(-lc++)
endif()

if(DEFINED EMSCRIPTEN)
    add_compile_options(-fwasm-exceptions)
    add_compile_options(-pthread)
    add_compile_options(-matomics)

    add_link_options(-fwasm-exceptions)
    add_link_options(-pthread)
    add_link_options(-sPROXY_TO_PTHREAD)
    add_link_options(-sALLOW_MEMORY_GROWTH)
    add_link_options(-sEXIT_RUNTIME)
endif()


