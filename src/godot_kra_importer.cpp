#include "godot_kra_importer.h"

using namespace godot;

void KraImporter::_register_methods()
{
    register_method("load", &KraImporter::load);
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

    /* Convert wstring to string */
    const char *char_path = p_path.alloc_c_string();
    std::wstring ws = std::wstring_convert<std::codecvt_utf8<wchar_t>>().from_bytes(char_path);
    document->load(ws);
}