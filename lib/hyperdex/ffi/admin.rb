require 'ffi'
require 'ffi/enum_generator'

module HyperDex::FFI::Admin
	extend ::FFI::Library
	ffi_lib ['hyperdex-admin.so.0', 'hyperdex-admin.0']

	generate_enum :hyperdex_admin_returncode do |eg|
		eg.include "hyperdex/admin.h"

		%w{SUCCESS

		   NOMEM NONEPENDING POLLFAILED TIMEOUT INTERRUPTED SERVERERROR
		   COORDFAIL BADSPACE DUPLICATE NOTFOUND LOCALERROR

		   INTERNAL EXCEPTION GARBAGE
		}.each do |suffix|
			eg.symbol("HYPERDEX_ADMIN_#{suffix}", suffix)
		end
	end

	attach_function :create,
	                :hyperdex_admin_create,
	                [:pointer, :ushort],
	                :pointer
	attach_function :destroy,
	                :hyperdex_admin_destroy,
	                [:pointer],
	                :void

	attach_function :loop,
	                :hyperdex_admin_loop,
	                [:pointer, :int, :pointer],
	                :int64_t

	attach_function :add_space,
	                :hyperdex_admin_add_space,
	                [:pointer, :pointer, :pointer],
	                :int64_t
	attach_function :list_spaces,
	                :hyperdex_admin_list_spaces,
	                [:pointer, :pointer, :pointer],
	                :int64_t
	attach_function :rm_space,
	                :hyperdex_admin_rm_space,
	                [:pointer, :pointer, :pointer],
	                :int64_t

	attach_function :returncode_to_string,
	                :hyperdex_admin_returncode_to_string,
	                [:int],
	                :pointer
end
