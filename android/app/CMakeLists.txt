cmake_minimum_required(VERSION 3.4.1)

add_library( # Sets the name of the library.
        engine

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        src/main/cpp/cchess-engine.cpp
        src/main/cpp/engine/command-channel.cpp
        src/main/cpp/engine/command-queue.cpp
        src/main/cpp/engine/book.cpp
        src/main/cpp/engine/eleeye.cpp
        src/main/cpp/engine/evaluate.cpp
        src/main/cpp/engine/genmoves.cpp
        src/main/cpp/engine/hash.cpp
        src/main/cpp/engine/movesort.cpp
        src/main/cpp/engine/position.cpp
        src/main/cpp/engine/preeval.cpp
        src/main/cpp/engine/pregen.cpp
        src/main/cpp/engine/search.cpp
        src/main/cpp/engine/ucci.cpp)


find_library( # Sets the name of the path variable.
        log-lib

        # Specifies the name of the NDK library that
        # you want CMake to locate.
        log)


target_link_libraries( # Specifies the target library.
        engine

        # Links the target library to the log library
        # included in the NDK.
        ${log-lib})