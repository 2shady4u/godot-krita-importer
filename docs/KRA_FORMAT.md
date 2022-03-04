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

...

## `layer2`, `layer3`, ...

...
