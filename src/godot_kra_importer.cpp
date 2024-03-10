#include "godot_kra_importer.h"

using namespace godot;

void KraImporter::_bind_methods()
{
    // Methods.
    ClassDB::bind_method(D_METHOD("load", "path"), &KraImporter::load);
    ClassDB::bind_method(D_METHOD("get_layer_data_at", "layer_index"), &KraImporter::get_layer_data_at);
    ClassDB::bind_method(D_METHOD("get_layer_data_with_uuid", "UUID"), &KraImporter::get_layer_data_with_uuid);

    // Properties.
    ClassDB::bind_method(D_METHOD("set_layer_count"), &KraImporter::set_layer_count);
	ClassDB::bind_method(D_METHOD("get_layer_count"), &KraImporter::get_layer_count);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "layer_count"), "set_layer_count", "get_layer_count");

    ClassDB::bind_method(D_METHOD("set_verbosity_level"), &KraImporter::set_verbosity_level);
	ClassDB::bind_method(D_METHOD("get_verbosity_level"), &KraImporter::get_verbosity_level);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "verbosity_level"), "set_verbosity_level", "get_verbosity_level");
}

KraImporter::KraImporter()
{
    document = std::make_unique<kra::Document>();
}

KraImporter::~KraImporter()
{
}

void KraImporter::load(String p_path)
{
    /* Find the real path */
    p_path = ProjectSettings::get_singleton()->globalize_path(p_path.strip_edges());

    /* Convert wstring to string */
    const CharString dummy_path = p_path.utf8();
    const char *char_path = dummy_path.get_data();
    std::wstring ws = std::wstring_convert<std::codecvt_utf8<wchar_t>>().from_bytes(char_path);
    document->load(ws);
}

Dictionary KraImporter::get_layer_data_at(int p_layer_index)
{
    if (p_layer_index >= 0 && p_layer_index < document->layers.size())
    {
        std::unique_ptr<kra::ExportedLayer> exported_layer = std::make_unique<kra::ExportedLayer>();
        exported_layer = document->get_exported_layer_at(p_layer_index);

        return _get_layer_data(exported_layer);
    }
    else
    {
        UtilityFunctions::printerr("Error: Index " + String(std::to_string(p_layer_index).c_str()) + " is out of range, should be between 0 and " + String(std::to_string(document->layers.size()).c_str()));
        return Dictionary();
    }
}

Dictionary KraImporter::get_layer_data_with_uuid(String p_uuid)
{
    std::unique_ptr<kra::ExportedLayer> exported_layer = std::make_unique<kra::ExportedLayer>();
    const CharString dummy_uuid = p_uuid.utf8();
    const char *char_uuid = dummy_uuid.get_data();
    exported_layer = document->get_exported_layer_with_uuid(char_uuid);

    return _get_layer_data(exported_layer);
}

Dictionary KraImporter::_get_layer_data(const std::unique_ptr<kra::ExportedLayer> &exported_layer)
{
    Dictionary layer_data;

    layer_data["name"] = String(exported_layer->name.c_str());
    unsigned int width = exported_layer->right - exported_layer->left;
    layer_data["width"] = width;
    unsigned int height = exported_layer->bottom - exported_layer->top;
    layer_data["height"] = height;

    layer_data["position"] = Vector2(exported_layer->left + (int32_t)exported_layer->x, exported_layer->top + (int32_t)exported_layer->y);

    layer_data["opacity"] = exported_layer->opacity;
    layer_data["visible"] = exported_layer->visible;

    layer_data["type"] = exported_layer->type;

    unsigned int pixel_size = exported_layer->pixel_size;
    switch (exported_layer->type)
    {
    case kra::PAINT_LAYER:
    {
        switch (exported_layer->color_space)
        {
        case kra::RGBA:
            layer_data["format"] = Image::FORMAT_RGBA8;
            break;
        case kra::RGBAF32:
            layer_data["format"] = Image::FORMAT_RGBAF;
            break;
        default:
            /* Godot doesn't support any of the other color spaces so we'll just pretend that they are RGBA */
            UtilityFunctions::printerr("Error: Importing an image with the '" + String(kra::get_color_space_name(exported_layer->color_space).c_str()) + "' color space is not supported by Godot!");
            layer_data["format"] = Image::FORMAT_RGBA8;
            /* Also force the pixel_size to 4 */
            pixel_size = 4;
            break;
        }

        int bytes = width * height * pixel_size;
        PackedByteArray arr = PackedByteArray();
        arr.resize(bytes);

        if (exported_layer->color_space == kra::RGBA || exported_layer-> color_space == kra::RGBAF32)
        {
            memcpy((void *)arr.ptrw(), exported_layer->data.data(), bytes);
            layer_data["data"] = arr;
        }
        else
        {
            /* This is mainly here to stop Godot from crashing whenever someone tries to import a non-supported color space*/
            // NOTE: I'm not really what this data will be populated with? Random junk?
            layer_data["data"] = arr;
        }
        break;
    }
    case kra::GROUP_LAYER:
    {
        int bytes = exported_layer->child_uuids.size();
        PackedStringArray arr = PackedStringArray();
        for (const auto &uuid : exported_layer->child_uuids)
        {
            arr.push_back(uuid.c_str());
        }
        layer_data["child_uuids"] = arr;
        break;
    }
    default:
        break;
    }

    return layer_data;
}

void KraImporter::set_layer_count(int p_layer_count)
{
    // This isn't allowed!
}

int KraImporter::get_layer_count()
{
    return document->layers.size();
}

void KraImporter::set_verbosity_level(int p_verbosity_level)
{
    kra::verbosity_level = (kra::VerbosityLevel)p_verbosity_level;
}

int KraImporter::get_verbosity_level()
{
    return kra::verbosity_level;
}