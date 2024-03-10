#ifndef KRA_IMPORTER_REGISTER_TYPES_H
#define KRA_IMPORTER_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>
using namespace godot;

void initialize_kra_importer_module(ModuleInitializationLevel p_level);
void uninitialize_kra_importer_module(ModuleInitializationLevel p_level);

#endif // ! KRA_IMPORTER_REGISTER_TYPES_H