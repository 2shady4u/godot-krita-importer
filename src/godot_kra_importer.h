#ifndef KRA_IMPORTER_H
#define KRA_IMPORTER_H

#include <godot_cpp/variant/utility_functions.hpp>

#include <godot_cpp/classes/project_settings.hpp>
#include <godot_cpp/classes/image.hpp>

#include <codecvt>
#include <locale>
#include <memory>

#include "libkra/libkra/kra_document.h"

namespace godot
{
    class KraImporter : public RefCounted
    {
        GDCLASS(KraImporter, RefCounted)

    private:
        std::unique_ptr<kra::Document> document;

        Dictionary _get_layer_data(const std::unique_ptr<kra::ExportedLayer> &exported_layer);

    protected:
        static void _bind_methods();

    public:
        KraImporter();
        ~KraImporter();

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