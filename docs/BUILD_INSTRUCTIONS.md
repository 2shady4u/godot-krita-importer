# build-instructions

Compilation of this plugin is supported on Windows, Linux and MacOS.
This document mainly focuses on compiling the binaries for Windows, but other platforms require the exact same steps with minor alterations.

As a first step, this repository needs to be cloned and the submodules need to be initialized using the following terminal commands:
```
git clone https://github.com/2shady4u/godot-krita-importer.git
cd godot-krita-importer
git submodule update --init --recursive
```

### Installation pre-requisites:
see https://docs.godotengine.org/en/stable/development/compiling/compiling_for_windows.html

## 1. Compile Godot Krita Importer

Compile the plugin using following commands:

```
scons p=<platform> target=<target>
```

with valid platform values being either `windows`, `linux` or `macos` and valid target values being `template_debug` or `template_release`.

***NOTE:** Both platform & target should be exact same as in previous step!*

Congratulations! You have successfully compiled the plugin!

---

For further specifics regarding the exact steps in the compilation process, please check out the `.github\workflows\*.yml`- and `SConstruct`-scripts as found in this repository.

Additional documentation regarding godot-cpp and information on how to make your own C++ plugins is available [here](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/gdextension_cpp_example.html).
