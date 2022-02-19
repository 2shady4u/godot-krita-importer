#ifndef KRA_IMPORTER_H
#define KRA_IMPORTER_H

#include <Godot.hpp>
#include <ProjectSettings.hpp>
#include <Image.hpp>

#include <codecvt>
#include <locale>
#include <memory>

#include "libkra/src/Kra/kra_file.h"

namespace godot
{
    class KraImporter : public Reference
    {
        GODOT_CLASS(KraImporter, Reference)

    private:
        std::unique_ptr<KraFile> document;

        Dictionary _get_layer_data(const std::unique_ptr<KraExportedLayer> &exported_layer);

    public:
        int layer_count;

        static void _register_methods();

        KraImporter();
        ~KraImporter();

        void _init();

        void load(String p_path);

        Dictionary get_layer_data_at(int p_layer_index);
        Dictionary get_layer_data_with_uuid(String p_uuid);

        void set_layer_count(int p_layer_count);
        int get_layer_count();
    };

}

#endif // KRA_IMPORTER_H