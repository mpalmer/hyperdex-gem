require "mkmf"

# Bloody hyperdex assumes you've got this in your include path... WHYYYYY?!!?
$defs.push "-I#{RbConfig::CONFIG['rubyhdrdir']}/ruby"

dir_config('hyperdex')
$libs = append_library($libs, with_config('hyperdexlib', 'hyperdex-client'))

$srcs = %w{admin.c client.c hyperdex.c}

create_makefile('hyperdex')
