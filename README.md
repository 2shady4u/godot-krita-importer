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
  - [Methods](#methods)
- [FAQ](#faq)
- [How to contribute?](#how-to-contribute)

# <a name="how-to-install">How to install?</a>

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

It's also possible to manually download the build files found in the [releases](https://github.com/2shady4u/godot-krita-importer/releases) tab, extract them on your system and run the supplied demo-project. Make sure that Godot is correctly loading the `libkra_importer.gdextension`-resource and that it is available in the `res://`-environment.

An example project, named "demo", can also be downloaded from the releases tab.

# <a name="how-to-use">How to use?</a>

Godot Krita Importer automatically imports any and all files with the KRA and KRZ-extensions and this should be sufficient for most purposes.

Krita                      |  Godot
:-------------------------:|:-------------------------:
![Krita source file](readme/krita_source_file.png?raw=true "Krita source file") | ![Imported result in Godot](readme/godot_imported_scene.png?raw=true "Imported result in Godot")

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

## <a name="methods">Methods</a>

- void **load(** String path **)**

    Load a KRA or KRZ-archive file and populate the internal layer structure.

- Dictionary layer_data = **get_layer_data_at(** Integer layer_index **)**

    Return the layer_data of the layer at the given top-level index.

- Dictionary layer_data = **get_layer_data_with_uuid(** String UUID **)**

    Return the layer_data of the layer with the given UUID.

## <a name="faq">Frequently Asked Questions (FAQ)</a>

### 1. Why are the colors of my imported `.kr(a/z)`-file different in Godot?

The C++ library [libkra](https://github.com/2shady4u/libkra), used for importing Krita documents into Godot, does not support nor implement any conversion between [color profiles](https://en.wikipedia.org/wiki/ICC_profile). As a result, the color profile used for your Krita document should be the exact same as the one implemented in Godot otherwise the color of your pixels will different across applications.

In the case of Godot, this means that you'll have to choose the `sRGB IEC61966-2.1` color profile for all your Krita documents (Image -> Properties).

Future improvements in the `libkra`-library might see the implementation of color profile awareness and conversion, most likely by using the [Little CMS](https://www.littlecms.com/) library as an additional external dependency in the project.

### 2. Why is my favorite color space `XYZ` not supported by this plugin?

Only a small selection of color space formats are currently supported by this plugin. 
This might be because one of two possible reasons:

1. The C++ `libkra`-library does not implement this format
2. Godot does not natively support the format 

Supported formats can be listed as follows:

|           | Supported by `libkra`? | Supported by Godot? (`Image::Format`) |
|-----------|:----------------------:|:-------------------------------------:|
| `RGBA`    | :heavy_check_mark:     | `Image::FORMAT_RGBA`                  |
| `RGBA16`  | :heavy_check_mark:     | :x:*                                  |
| `RGBAF16` | :heavy_check_mark:     | :x:*                                  |
| `RGBAF32` | :heavy_check_mark:     | `Image::FORMAT_RGBAF`                 |
| `CMYK`    | :heavy_check_mark:     | :x:*                                  |

\* *Godot does **not** natively support this color space format*

In cases where your favorite color format `XYZ` is natively supported by Godot, but is unfortunately blatently absent from the above color space support matrix, please feel free to open an issue in this repository.

### 3. Is support for `*.xcf`, `*.ora`, `*.psd`, etc... in the list of planned features?

No other file formats will ever be supported.

# <a name="how-to-contribute">How to contribute?</a>

Build instructions for all supported platforms can be found [here](docs/BUILD_INSTRUCTIONS.md).

Please feel free to open pull requests as to merge any contributions into this repository.