require "mkmf"

$defs.push "-DHYPERDEX_CLIENT"

dir_config('hyperdex')
$libs = append_library($libs, 'hyperdex-client')

$srcs = %w{client.c hyperdex.c}

create_makefile('_hyperdex')
