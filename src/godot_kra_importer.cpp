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
}

void KraImporter::load(String p_path)
{
    Godot::print("load");
}