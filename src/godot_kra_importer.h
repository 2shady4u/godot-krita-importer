#ifndef KRA_IMPORTER_H
#define KRA_IMPORTER_H

#include <Godot.hpp>

namespace godot
{
    class KraImporter : public Reference
    {
        GODOT_CLASS(KraImporter, Reference)

    public:
        static void _register_methods();

        KraImporter();
        ~KraImporter();

        void _init();

        void load(String p_path);
    };

}

#endif // KRA_IMPORTER_H