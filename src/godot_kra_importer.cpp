#include "godot_kra_importer.h"

using namespace godot;

void KraImporter::_register_methods()
{
    register_method("load", &KraImporter::load);
    register_method("get_layer_data", &KraImporter::get_layer_data);

    register_property<KraImporter, int>("layer_count", &KraImporter::set_layer_count, &KraImporter::get_layer_count, 0);
}

KraImporter::KraImporter()
{
}

KraImporter::~KraImporter()
{
}

void KraImporter::_init()
{
    document = std::make_unique<KraFile>();
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

Dictionary KraImporter::get_layer_data(int p_layer_index)
{
    Dictionary layer_data;

    if (p_layer_index < 0 || p_layer_index >= document->layers.size())
    {
        Godot::print("layer index is out of bounds");
    }
    else 
    {
        Godot::print("layer index is inside of the bounds");

        std::unique_ptr<KraExportedLayer> exported_layer = std::make_unique<KraExportedLayer>();
        exported_layer = document->get_exported_layer(p_layer_index);

        layer_data["name"] = exported_layer->name;
        unsigned int width = exported_layer->right - exported_layer->left;
        layer_data["width"] = width;
        unsigned int height = exported_layer->bottom - exported_layer->top;
        layer_data["height"] = height;

        layer_data["position"] = Vector2(exported_layer->left, exported_layer->top);

        int bytes = width * height * exported_layer->channelCount;
        PoolByteArray arr = PoolByteArray();
        arr.resize(bytes);
        PoolByteArray::Write write = arr.write();
        memcpy(write.ptr(), exported_layer->data.get(), bytes);

        layer_data["data"] = arr;
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