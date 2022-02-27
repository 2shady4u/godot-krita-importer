#ifndef KRA_IMPORTER_H
#define KRA_IMPORTER_H

#include <Godot.hpp>
#include <ProjectSettings.hpp>
#include <Image.hpp>

#include <codecvt>
#include <locale>
#include <memory>

#include "libkra/libkra/kra_document.h"

namespace godot
{
    class KraImporter : public Reference
    {
        GODOT_CLASS(KraImporter, Reference)

    private:
        std::unique_ptr<kra::Document> document;

        Dictionary _get_layer_data(const std::unique_ptr<kra::ExportedLayer> &exported_layer);

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

        void set_verbosity_level(int p_verbosity_level);
        int get_verbosity_level();
    };

}

#endif // KRA_IMPORTER_H