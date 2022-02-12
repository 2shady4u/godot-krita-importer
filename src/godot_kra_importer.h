#ifndef KRA_IMPORTER_H
#define KRA_IMPORTER_H

#include <Godot.hpp>

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

    public:
        static void _register_methods();

        KraImporter();
        ~KraImporter();

        void _init();

        void load(String p_path);
    };

}

#endif // KRA_IMPORTER_H