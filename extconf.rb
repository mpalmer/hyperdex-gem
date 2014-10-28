require "mkmf"

# Bloody hyperdex assumes you've got this in your include path... WHYYYYY?!!?
$defs.push "-I#{RbConfig::CONFIG['rubyhdrdir']}/ruby"

# And we need these, because hyperdex is stupid
$defs.push "-DHYPERDEX_CLIENT"

dir_config('hyperdex')
$libs = append_library($libs, 'hyperdex-client')

# Yes, we have .c files in here that shouldn't be compiled.  WHHYYYYYYY?!?!?!
$srcs = %w{client.c hyperdex.c}

create_makefile('hyperdex')
