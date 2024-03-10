#!/usr/bin/env python
import os
import sys

target_path = ARGUMENTS.pop("target_path", "demo/addons/godot-krita-importer/bin/")
target_name = ARGUMENTS.pop("target_name", "libkra_importer")

env = SConscript("godot-cpp/SConstruct")

target = "{}{}".format(
    target_path, target_name
)

# For the reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
libkra_path = "libkra/"
env.Append(CPPPATH=[
    ".",
    libkra_path + "zlib/"
])
env.Append(CPPPATH=["src/"])

sources = [
    Glob('src/*.cpp'),
    Glob(libkra_path + 'zlib/*.c'),
    Glob(libkra_path + 'libkra/*.cpp'),
    libkra_path + 'tinyxml2/tinyxml2.cpp',
    libkra_path + 'zlib/contrib/minizip/unzip.c',
    libkra_path + 'zlib/contrib/minizip/ioapi.c'
]

if env["platform"] == "macos":
    target = "{}.{}.{}.framework/{}.{}.{}".format(
        target,
        env["platform"], 
        env["target"],
        target_name,
        env["platform"],
        env["target"]
    )
else:
    target = "{}{}{}".format(
        target,
        env["suffix"],
        env["SHLIBSUFFIX"]
    )

library = env.SharedLibrary(target=target, source=sources)
Default(library)