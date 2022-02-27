#!/usr/bin/env python

import os
import sys
import subprocess

if sys.version_info < (3,):
    def decode_utf8(x):
        return x
else:
    import codecs
    def decode_utf8(x):
        return codecs.utf_8_decode(x)[0]

# Workaround for MinGW. See:
# http://www.scons.org/wiki/LongCmdLinesOnWin32
if (os.name=="nt"):
    import subprocess

    def mySubProcess(cmdline,env):
        #print "SPAWNED : " + cmdline
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        proc = subprocess.Popen(cmdline, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, startupinfo=startupinfo, shell = False, env = env)
        data, err = proc.communicate()
        rv = proc.wait()
        if rv:
            print("=====")
            print(err.decode("utf-8"))
            print("=====")
        return rv

    def mySpawn(sh, escape, cmd, args, env):

        newargs = ' '.join(args[1:])
        cmdline = cmd + " " + newargs

        rv=0
        if len(cmdline) > 32000 and cmd.endswith("ar") :
            cmdline = cmd + " " + args[1] + " " + args[2] + " "
            for i in range(3,len(args)) :
                rv = mySubProcess( cmdline + args[i], env )
                if rv :
                    break
        else:
            rv = mySubProcess( cmdline, env )

        return rv

def add_sources(sources, dir, extension):
    for f in os.listdir(dir):
        if f.endswith('.' + extension):
            sources.append(dir + '/' + f)

#################
#OPTIONS#########
#################

# Try to detect the host platform automatically.
# This is used if no `platform` argument is passed
if sys.platform.startswith('linux'):
    host_platform = 'linux'
elif sys.platform == 'darwin':
    host_platform = 'osx'
elif sys.platform == 'win32' or sys.platform == 'msys':
    host_platform = 'windows'
else:
    raise ValueError(
        'Could not detect platform automatically, please specify with '
        'platform=<platform>'
    )

# Gets the standard flags CC, CCX, etc.
env = Environment(ENV = os.environ)

is64 = sys.maxsize > 2**32
if (
    env['TARGET_ARCH'] == 'amd64' or
    env['TARGET_ARCH'] == 'emt64' or
    env['TARGET_ARCH'] == 'x86_64' or
    env['TARGET_ARCH'] == 'arm64-v8a'
):
    is64 = True

opts = Variables([], ARGUMENTS)
# Define our options
opts.Add(EnumVariable(
    'platform',
    'Target platform',
    host_platform,
    allowed_values=('linux', 'osx', 'windows'),
    ignorecase=2
))
opts.Add(EnumVariable(
    'bits',
    'Target platform bits',
    '64' if is64 else '32',
    ('32', '64')
))
opts.Add(BoolVariable(
    'use_llvm',
    'Use the LLVM compiler - only effective when targeting Linux',
    False
))
opts.Add(BoolVariable(
    'use_mingw',
    'Use the MinGW compiler instead of MSVC - only effective on Windows',
    False
))
# Must be the same setting as used for cpp_bindings
opts.Add(EnumVariable(
    'target',
    'Compilation target',
    'debug',
    allowed_values=('debug', 'release'),
    ignorecase=2
))
opts.Add(
    'macos_deployment_target',
    'macOS deployment target',
    'default'
)
opts.Add(
    'macos_sdk_path',
    'macOS SDK path',
    ''
)
opts.Add(EnumVariable(
    'macos_arch',
    'Target macOS architecture',
    'universal',
    ['universal', 'x86_64', 'arm64']
))
opts.Add(PathVariable(
    'target_path', 
    'The path where the lib is installed.', 
    'demo/addons/godot-krita-importer/bin/'
))
opts.Add(PathVariable(
    'target_name', 
    'The library name.', 
    'libkra_importer', 
    PathVariable.PathAccept
))

# Local dependency paths, adapt them to your setup
godot_headers_path = "godot-cpp/godot-headers/"
cpp_bindings_path = "godot-cpp/"
libkra_path = "libkra/"

# Updates the environment with the option variables.
opts.Update(env)
# Generates help for the -h scons option.
Help(opts.GenerateHelpText(env))

# For the reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# This makes sure to keep the session environment variables on Windows.
# This way, you can run SCons in a Visual Studio 2017 prompt and it will find
# all the required tools
if host_platform == 'windows':
    if env['bits'] == '64':
        env = Environment(TARGET_ARCH='amd64')
    elif env['bits'] == '32':
        env = Environment(TARGET_ARCH='x86')

    opts.Update(env)

###################
####FLAGS##########
###################

if env['platform'] == 'linux':
    env['target_path'] += "x11/"

    if env['use_llvm']:
        env['CC'] = 'clang'
        env['CXX'] = 'clang++'

    env.Append(CCFLAGS=['-fPIC'])
    # To compile zlib on Linux without any warning, an additional compiler flag needs to be added here!
    # This is similar to the exact same compiler flag added for macOS targets... except without the crash!
    env.Append(CCFLAGS=['-DHAVE_UNISTD_H'])
    env.Append(CXXFLAGS=['-std=c++17'])
    if env['target'] == 'debug':
        env.Append(CCFLAGS = ['-g3','-Og'])
    elif env['target'] == 'release':
        env.Append(CCFLAGS = ['-O3'])
        env.Append(LINKFLAGS = ['-s'])

    if env['bits'] == '64':
        env.Append(CCFLAGS=['-m64'])
        env.Append(LINKFLAGS=['-m64'])
    elif env['bits'] == '32':
        env.Append(CCFLAGS=['-m32'])
        env.Append(LINKFLAGS=['-m32'])

elif env['platform'] == 'osx':
    env['target_path'] += "osx/"

    # Use Clang on macOS by default
    env['CC'] = 'clang'
    env['CXX'] = 'clang++'

    if env['bits'] == '32':
        raise ValueError(
            'Only 64-bit builds are supported for the macOS target.'
        )

    if env["macos_arch"] == "universal":
        env.Append(LINKFLAGS=["-arch", "x86_64", "-arch", "arm64"])
        env.Append(CCFLAGS=["-arch", "x86_64", "-arch", "arm64"])
    else:
        env.Append(LINKFLAGS=["-arch", env["macos_arch"]])
        env.Append(CCFLAGS=["-arch", env["macos_arch"]])

    # For compiling zlib on macOS, an additional compiler flag needs to be added!
    # See: https://github.com/HaxeFoundation/hxcpp/issues/723
    env.Append(CCFLAGS=['-DHAVE_UNISTD_H'])
    env.Append(CXXFLAGS=['-std=c++17'])

    if env['macos_deployment_target'] != 'default':
        env.Append(CCFLAGS=['-mmacosx-version-min=' + env['macos_deployment_target']])
        env.Append(LINKFLAGS=['-mmacosx-version-min=' + env['macos_deployment_target']])

    if env['macos_sdk_path']:
        env.Append(CCFLAGS=['-isysroot', env['macos_sdk_path']])
        env.Append(LINKFLAGS=['-isysroot', env['macos_sdk_path']])

    env.Append(LINKFLAGS=[
        '-framework',
        'Cocoa',
        '-Wl,-undefined,dynamic_lookup',
    ])

    if env['target'] == 'debug':
        env.Append(CCFLAGS=['-Og', 'g'])
    elif env['target'] == 'release':
        env.Append(CCFLAGS=['-O3'])

elif env['platform'] == 'windows':
    env['target_path'] += "win64/"

    if host_platform == 'windows' and not env['use_mingw']:
        # MSVC
        env.Append(LINKFLAGS=['/WX'])
        if env['target'] == 'debug':
            env.Append(CCFLAGS=['/Z7', '/Od', '/EHsc', '/D_DEBUG', '/MDd'])
        elif env['target'] == 'release':
            env.Append(CCFLAGS=['/O2', '/EHsc', '/DNDEBUG', '/MD'])

    elif host_platform == 'linux' or host_platform == 'osx':
        # Cross-compilation using MinGW
        if env['bits'] == '64':
            env['CC'] = 'x86_64-w64-mingw32-gcc'
            env['CXX'] = 'x86_64-w64-mingw32-g++'
            env['AR'] = "x86_64-w64-mingw32-ar"
            env['RANLIB'] = "x86_64-w64-mingw32-ranlib"
            env['LINK'] = "x86_64-w64-mingw32-g++"
        elif env['bits'] == '32':
            env['CC'] = 'i686-w64-mingw32-gcc'
            env['CXX'] = 'i686-w64-mingw32-g++'
            env['AR'] = "i686-w64-mingw32-ar"
            env['RANLIB'] = "i686-w64-mingw32-ranlib"
            env['LINK'] = "i686-w64-mingw32-g++"

    elif host_platform == 'windows' and env['use_mingw']:
        # Don't Clone the environment. Because otherwise, SCons will pick up msvc stuff.
        env = Environment(ENV = os.environ, tools=["mingw"])
        opts.Update(env)
        #env = env.Clone(tools=['mingw'])

        env["SPAWN"] = mySpawn

    # Native or cross-compilation using MinGW
    if host_platform == 'linux' or host_platform == 'osx' or env['use_mingw']:
        env.Append(CCFLAGS=['-O3', '-Wwrite-strings'])
        env.Append(CXXFLAGS=['-std=c++17'])
        env.Append(LINKFLAGS=[
            '--static',
            '-Wl,--no-undefined',
            '-static-libgcc',
            '-static-libstdc++',
        ])

#####################
#ADD SOURCES#########
#####################
env.Append(CPPPATH=[
    '.', 
    godot_headers_path, 
    cpp_bindings_path + 'include/', 
    cpp_bindings_path + 'include/core/', 
    cpp_bindings_path + 'include/gen/',
    libkra_path + 'zlib/'
])
env.Append(CPPPATH=['src/'])

arch_suffix = env['bits']
cpp_bindings_libname = 'libgodot-cpp.{}.{}.{}'.format(
                        env['platform'],
                        env['target'],
                        arch_suffix)

env.Append(LIBS=[cpp_bindings_libname])
env.Append(LIBPATH=[cpp_bindings_path + 'bin/'])

sources = [
    Glob('src/*.cpp'),
    Glob(libkra_path + 'zlib/*.c'),
    Glob(libkra_path + 'libkra/*.cpp'),
    libkra_path + 'tinyxml2/tinyxml2.cpp',
    libkra_path + 'zlib/contrib/minizip/unzip.c',
    libkra_path + 'zlib/contrib/minizip/ioapi.c'
]

###############
#BUILD LIB#####
###############

library = env.SharedLibrary(target=env['target_path'] + env['target_name'], source=sources)

Default(library)