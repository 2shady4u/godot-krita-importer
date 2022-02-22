#include "godot_kra_importer.h"

using namespace godot;

void KraImporter::_register_methods()
{
    register_method("load", &KraImporter::load);
    register_method("get_layer_data_at", &KraImporter::get_layer_data_at);
    register_method("get_layer_data_with_uuid", &KraImporter::get_layer_data_with_uuid);

    register_property<KraImporter, int>("layer_count", &KraImporter::set_layer_count, &KraImporter::get_layer_count, 0);
    register_property<KraImporter, int>("verbosity_level", &KraImporter::set_verbosity_level, &KraImporter::get_verbosity_level, 0);
}

KraImporter::KraImporter()
{
}

KraImporter::~KraImporter()
{
}

void KraImporter::_init()
{
    document = std::make_unique<KraDocument>();
}

void KraImporter::load(String p_path)
{
    Godot::print("load");

    /* Find the real path */
    p_path = ProjectSettings::get_singleton()->globalize_path(p_path.strip_edges());

    /* Convert wstring to string */
    const char *char_path = p_path.alloc_c_string();
    std::wstring ws = std::wstring_convert<std::codecvt_utf8<wchar_t>>().from_bytes(char_path);
    document->load(ws);
}

Dictionary KraImporter::get_layer_data_at(int p_layer_index)
{
    if (p_layer_index < 0 || p_layer_index >= document->layers.size())
    {
        Godot::print("layer index is out of bounds");
        return Dictionary();
    }
    else
    {
        Godot::print("layer index is inside of the bounds");

        std::unique_ptr<KraExportedLayer> exported_layer = std::make_unique<KraExportedLayer>();
        exported_layer = document->get_exported_layer_at(p_layer_index);

        return _get_layer_data(exported_layer);
    }
}

Dictionary KraImporter::get_layer_data_with_uuid(String p_uuid)
{
    std::unique_ptr<KraExportedLayer> exported_layer = std::make_unique<KraExportedLayer>();
    exported_layer = document->get_exported_layer_with_uuid(p_uuid.alloc_c_string());

    return _get_layer_data(exported_layer);
}

Dictionary KraImporter::_get_layer_data(const std::unique_ptr<KraExportedLayer> &exported_layer)
{
    Dictionary layer_data;

    layer_data["type"] = exported_layer->type;
    layer_data["name"] = String(exported_layer->name.c_str());
    unsigned int width = exported_layer->right - exported_layer->left;
    layer_data["width"] = width;
    unsigned int height = exported_layer->bottom - exported_layer->top;
    layer_data["height"] = height;

    layer_data["position"] = Vector2(exported_layer->left + (int32_t)exported_layer->x, exported_layer->top + (int32_t)exported_layer->y);

    layer_data["opacity"] = exported_layer->opacity;
    layer_data["visible"] = exported_layer->visible;

    switch (exported_layer->type)
    {
    case kra::PAINT_LAYER:
    {
        switch (exported_layer->channel_count)
        {
        case 4:
            layer_data["format"] = Image::FORMAT_RGBA8;
            break;
        case 3:
            /* This might actually not be possible! */
            layer_data["format"] = Image::FORMAT_RGB8;
            break;
        }

        int bytes = width * height * exported_layer->channel_count;
        PoolByteArray arr = PoolByteArray();
        arr.resize(bytes);
        PoolByteArray::Write write = arr.write();
        memcpy(write.ptr(), exported_layer->data.get(), bytes);

        layer_data["data"] = arr;
        break;
    }
    case kra::GROUP_LAYER:
    {
        int bytes = exported_layer->child_uuids.size();
        PoolStringArray arr = PoolStringArray();
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