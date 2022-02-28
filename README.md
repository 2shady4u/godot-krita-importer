# godot-krita-importer

Plugin for Godot Engine to automatically import Krita KRA & KRZ-files

### Supported operating systems:
- Mac OS X
- Linux
- Windows

### Table Of Contents

- [How to use?](#how-to-use)
  - [Variables](#variables)
  - [Functions](#functions)

# <a name="how-to-use">How to use?</a>

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
