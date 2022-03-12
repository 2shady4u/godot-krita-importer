# kra-format

This document aims to describe the specifics of the `.kra`- and `.krz`-format in due detail.

***What's the difference between `.kra` & `.krz`?***

As found in Krita's [documentation](https://docs.krita.org/en/general_concepts/file_formats/file_kra.html):

> The `.krz` file format is a `.kra` file without `mergedimage.png` and with compression always  enabled. You can use this format if you want to save disk space and do not care about interchange with those applications that load the `mergedimage.png` file.

This plugin does not concern itself with the `mergedimage.png` file in any way or form and thus can be considered agnostic to the actual extension.

## Folder structure

Any `.kr(a/z)`-file is a zipped archive that contains the image's layout and layers in a binary format.  

When unzipping such a file, a folder/file structure similar to the following can be observed:

```
MyKritaFile/
- preview.png
- mimetype
- mergedimage.png
- maindoc.xml
- documentinfo.xml
- DocumentTitle/
- - annotations/
- - - ...
- - layers/
- - - layer2
- - - layer2.defaultpixel
- - - layer2.icc
- - - ...
```

Only a small selection of these files are actually useful for purposes of this plugin; namely the following:

**`maindoc.xml`**

    contains information about the document's layout and its layers' properties

**`layer2`, `layer3`, ...**

    contains the actual layer content in binary format

Both file types are now to be discussed in further detail.

## `maindoc.xml`

Possible content of this XML-document looks as follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE DOC PUBLIC '-//KDE//DTD krita 2.0//EN' 'http://www.calligra.org/DTD/krita-2.0.dtd'>
<DOC xmlns="http://www.calligra.org/DTD/krita" syntaxVersion="2.0" editor="Krita" kritaVersion="5.0.0">
 <IMAGE name="DocumentTitle" x-res="300" mime="application/x-kra" width="64" description="" height="64" profile="sRGB-elle-V2-srgbtrc.icc" y-res="300" colorspacename="RGBA">
  <layers>
   <layer y="0" locked="0" selected="true" collapsed="0" uuid="{43b51b85-9994-449d-86c9-0125292fa3f0}" opacity="255" compositeop="normal" intimeline="1" x="0" onionskin="0" visible="1" colorlabel="0" nodetype="paintlayer" filename="layer2" channellockflags="1111" colorspacename="RGBA" channelflags="" name="Background"/>
  </layers>
  <ProjectionBackgroundColor ColorData="AAAAAA=="/>
  <GlobalAssistantsColor SimpleColorData="176,176,176,255"/>
  <Palettes/>
  <resources/>
  <animation>
   <framerate value="24" type="value"/>
   <range from="0" to="100" type="timerange"/>
   <currentTime value="0" type="value"/>
  </animation>
 </IMAGE>
</DOC>
```

Important attributes, for the matter at hand, are contained in the `<IMAGE>` element as well as in each of the `<layer>` child elements. Furthermore the layer structure can be deduced by parsing the layout as contained in between the `<layers>` element's begin and end tag.

While most attributes are self-explanatory, there's a select few that benefit from further clarification:

### `<IMAGE>`

- `name`

    This is the document's name as set in Krita's document information and is important due to the fact that the folder containing the layers' binary data has the exact same name.

- `colorspacename`

    This is the document's reference color space. As each of the document's layers can have its own (potentially different) color space, this attribute is of lesser interest. 

### `<layer>`

- `filename`

    This is the name of the layer's binary data file as found in the `DocumentTitle/layers/`-folder. In which "`DocumentTitle`" is to be replaced with the value of the name attribute as found in the `<IMAGE>` element.

- `nodetype`

    This is the layer's type with possible values being `paintlayer`, `grouplayer`, `vectorlayer`, etc.

    Following types are supported by this plugin:

    - `paintlayer`

        Krita's default layer type which contains color data as stored in one of the binary data files in the `layers/`-folder. 

    - `grouplayer`

        A group layer is a layer which contains other layers. While there's a `filename` attribute in this element there's no corresponding binary file. Instead this layer's `<layer>` element contains a `<layers>` child element with identical structure as the `<IMAGE>` element's equivalent. 

- `colorspacename`

    This is the layer's color space which sets the binary data format of the layer's colors, possible values are:

    - `RGBA`

        4 color channels (red, green, blue & alpha) stored in 8-bit integer format

    - `RGBA16`

        4 color channels (red, green, blue & alpha) stored in 16-bit integer format

    - `RGBAF16`

        4 color channels (red, green, blue & alpha) stored in 16-bit floating-point format

    - `RGBAF32`

        4 color channels (red, green, blue & alpha) stored in 32-bit floating-point format

    - `CMYK`

        5 color channels (cyan, magenta, yellow, black & alpha) stored in 8-bit integer format

    - and many more...

***NOTE:** The layer's local position in the document (or its parent group layer) is found by adding the x (or y) attribute to the position of the left-most (or top-most) data tile (see next section).*

## `layer2`, `layer3`, ...

These are binary files in which the layer's color data is saved in a tile-based manner. The exact relationship between these tiles and the layer's data content can be easily demonstrated by using a simple example. 

Let's assume an entirely fictional Krita document with a single layer (called 'green') which can be depicted as such: 

![Tile Composition](kra_tile_composition.png?raw=true "Tile Composition")

A few important observations can be made:

- The layer content can exceed the boundaries of the image itself.
- The image (and the layer's binary content as a consequence) is subdivided into 64 x 64 pixel regions, so-called "tiles", starting from the image's top-leftmost corner.

In this example the content of the image's single layer spans across 4 different tiles and is stored as such as a result.

The actual **binary content** of a single layer file has following format:

```
VERSION 2
TILEWIDTH 64
TILEHEIGHT 64
PIXELSIZE 4
DATA 2
0,0,LZF,1258
0 or 1
  ^
  |
1257 bytes of data
  |
  v
0,0,LZF,1693
0 or 1
  ^
  |
1692 bytes of data
  |
  v
```

where each line is terminated by a Line Feed (`\x0A`) and in which the content can be separated into a layer header and multiple tile data blocks.

### Header

The layer's header contains following attributes:

- `VERSION`

    This is the version of the saved file and will always be equal to 2.

- `TILEWIDTH`

    The width of a tile (in pixels) which is 64 px. by default.

- `TILEHEIGHT`

    The height of a tile (in pixels) which is 64 px. by default.

- `PIXELSIZE`

    The number of bytes necessary to describe a single pixel which is 4 for the `RGBA` color format.

- `DATA`

    The number of tiles stored in this file.

Given these attributes the **uncompressed** size for storing the data of a single tile (which is the same for each tile in a single layer) can be calculated as:

```
UNCOMPRESSEDSIZE = TILEWIDTH*TILEHEIGHT*PIXELSIZE
```

### Data blocks

Each data block starts with a header of its own:

```
LEFT, TOP, LZF, COMPRESSEDSIZE
```

in which `LEFT` and `TOP` are the tile's horizontal and vertical positions respectively, `LZF` is the compression algorithm used for this tile (it's always `LZF`) and `COMPRESSEDSIZE` is the number of bytes following this header statement.

The byte following this tile's header gives an indication of this tile's compression status, with 0 and 1 being uncompressed and compressed respectively. Currently, this byte will always be 1 as the option to save your Krita document in uncompressed format is not yet implemented. (And there's no indication that it will ever be!)

After this, there will be `COMPRESSEDSIZE - 1` bytes which will need to be uncompressed, using the `LZF` decompression algorithm as found [here](https://invent.kde.org/kde/krita/-/blob/master/libs/image/tiles3/swap/kis_lzf_compression.cpp), as to obtain the actual tile data.

## Data format

After decompressing each of the tiles' data, the actual layer can be constructed by placing each of the tiles at its correct position as denoted by the `LEFT` and `TOP` attributes. Missing tiles denote regions in the layer without any content and are to be populated with the color space's zero value ( = 0000 for `RGBA`).

### Channel order

In the case of `RGBA16F` and `RGBA32F`, the pixel data is stored as such:

*R<sub>0</sub>R<sub>1</sub>R<sub>2</sub>...R<sub>end</sub> G<sub>0</sub>G<sub>1</sub>G<sub>2</sub>...G<sub>end</sub> B<sub>0</sub>B<sub>1</sub>B<sub>2</sub>...B<sub>end</sub> A<sub>0</sub>A<sub>1</sub>A<sub>2</sub>...A<sub>end</sub>*

with each channel value X<sub>i</sub> consisting of 2 or 4 bytes respectively and stored in little-endian byte order. The channel order for both `RGBA` and `RGBA16` is similar, but with **the red and blue channels swapped** for historic reasons.

Evidently, the bytes have to be re-arranged to a more conventional format to be applicable in other frameworks:  

*R<sub>0</sub>G<sub>0</sub>B<sub>0</sub>A<sub>0</sub> R<sub>1</sub>G<sub>1</sub>B<sub>1</sub>A<sub>1</sub> R<sub>2</sub>G<sub>2</sub>B<sub>2</sub>A<sub>2</sub> ... R<sub>end</sub>G<sub>end</sub>B<sub>end</sub>A<sub>end</sub>*

### Color profile

Krita stores each of the color values according to a color profile which needs to be consistent across applications. Failure to do so will inevitably result in images ending up with different colors than those seen in Krita.

Currently the `libkra`-library does not support out-of-the-box conversion between color profiles and thus it is **imperative** that the exact same color profile is chosen in both Krita as the targeted application (eg. Godot).

**In the case of the Godot plugin**, the `sRGB IEC61966-2.1` color profile should be chosen for all your `.kr(a/z)`-files, independent of the color space, and to ensure colors to stay consistent across applications.