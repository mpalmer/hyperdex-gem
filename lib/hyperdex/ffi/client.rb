require 'ffi'
require 'ffi/enum_generator'

module HyperDex::FFI::Client
	extend ::FFI::Library
	ffi_lib ['hyperdex-client.so.0', 'hyperdex-client.0']

	generate_enum :hyperdex_client_returncode do |eg|
		eg.include "hyperdex/client.h"

		%w{SUCCESS NOTFOUND SEARCHDONE CMPFAIL READONLY

		      UNKNOWNSPACE COORDFAIL SERVERERROR POLLFAILED OVERFLOW
		      RECONFIGURE TIMEOUT UNKNOWNATTR DUPEATTR NONEPENDING DONTUSEKEY
		      WRONGTYPE NOMEM INTERRUPTED CLUSTER_JUMP OFFLINE

		      INTERNAL EXCEPTION GARBAGE}.each do |suffix|
			eg.symbol("HYPERDEX_CLIENT_#{suffix}", suffix)
		end
	end

	attach_function :hyperdex_client_create,
	                [:pointer, :ushort],
	                :pointer
	attach_function :hyperdex_client_destroy,
	                [:pointer],
	                :void
	attach_function :hyperdex_client_destroy_attrs,
	                [:pointer, :size_t],
	                :void

	attach_function :hyperdex_client_error_message,
	                [:pointer],
	                :pointer
	attach_function :hyperdex_client_loop,
	                [:pointer, :int, :pointer],
	                :int64_t
	attach_function :hyperdex_client_poll,
	                [:pointer],
	                :int
	attach_function :hyperdex_client_returncode_to_string,
	                [:int],
	                :pointer
end
