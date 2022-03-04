![Godot Krita Importer banner](icon/godot-krita-importer-banner.png?raw=true "Godot Krita Importer Banner")

# godot-krita-importer

Plugin for Godot Engine to automatically import Krita KRA & KRZ-files

### Supported operating systems:
- Mac OS X
- Linux
- Windows

### Table Of Contents

- [How to install?](#how-to-install)
- [How to use?](#how-to-use)
  - [Variables](#variables)
  - [Functions](#functions)

# <a name="how-to-install">How to install?<a>

Re-building Godot from scratch is **NOT** required, the proper way of installing this plugin is to either install it through the Asset Library or to just manually download the build files yourself.

### Godot Asset Library

**Godot Krita Importer** is available through the official Godot Asset Library, and can be installed in the following way:

- Click on the 'AssetLib' button at the top of the editor.
- Search for 'Godot Krita Importer' and click on the resulting element.
- In the dialog pop-up, click 'Download'.
- Once the download is complete, click on the install button...
- Once more, click on the 'Install' button.
- Activate the plugin in the 'Project Settings/Plugins'-menu.
- All done!

### Manually

It's also possible to manually download the build files found in the [releases](https://github.com/2shady4u/godot-krita-importer/releases) tab, extract them on your system and run the supplied demo-project. Make sure that Godot is correctly loading the `gdsqlite.gdns`-resource and that it is available in the `res://`-environment.

An example project, named "demo", can also be downloaded from the releases tab.

# <a name="how-to-use">How to use?</a>

Godot Krita Importer automatically imports any and all files with the KRA and KRZ-extensions and this should be sufficient for most purposes.
  
In cases where more advanced importing functionality is wanted or required, the plugin exposes several variables and methods that hopefully allow enough freedom to easily extend the importer.

## <a name="variables">Variables</a>

- **layer_count** (Integer, default=0)

    Number of loaded layers at the top level of the document's layer structure. 

- **verbosity_level** (Integer, default=1)

    Verbosity level of the importer library, following levels are available:
    
    | Level            | Description                                 |
    |----------------- | ------------------------------------------- |
    | QUIET (0)        | Don't print anything to the console         |
    | NORMAL (1)       | Print essential information to the console  |
    | VERBOSE (2)      | Print additional information to the console |
    | VERY_VERBOSE (3) | Same as VERBOSE                             |
    
    ***NOTE:** VERBOSE and higher levels might considerably slow down the importing process due to excessive logging.*

## <a name="functions">Functions</a>

- void **load(** String path **)**

    Load a KRA or KRZ-archive file and populate the internal layer structure.

- Dictionary layer_data = **get_layer_data_at(** Integer layer_index **)**

    Return the layer_data of the layer at the given top-level index.

- Dictionary layer_data = **get_layer_data_with_uuid(** String UUID **)**

    Return the layer_data of the layer with the given UUID.
