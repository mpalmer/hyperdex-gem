require 'ffi'
require 'ffi/enum_generator'

module HyperDex::FFI::DS
	extend ::FFI::Library
	ffi_lib 'hyperdex-client.so.0'

	generate_enum :hyperdatatype do |eg|
		eg.include "hyperdex.h"

		[nil, "LIST", "SET"].each do |container|
			%w{GENERIC STRING INT64 FLOAT}.each do |type|
				suffix = [container, type].compact.join('_')
				eg.symbol("HYPERDATATYPE_#{suffix}", suffix)
			end
		end

		%w{STRING INT64 FLOAT}.each do |ktype|
			%w{KEYONLY STRING INT64 FLOAT}.each do |vtype|
				suffix = [ktype, vtype].join('_')
				eg.symbol("HYPERDATATYPE_MAP_#{suffix}", "MAP_#{suffix}")
			end
		end

		# Speciality types
		eg.symbol("HYPERDATATYPE_DOCUMENT", "DOCUMENT")
		eg.symbol("HYPERDATATYPE_MAP_GENERIC", "MAP_GENERIC")
		eg.symbol("HYPERDATATYPE_GARBAGE", "GARBAGE")
	end

	class DsIterator < ::FFI::Struct
		layout :datatype,  :hyperdatatype,
		       :value,     :pointer,
		       :value_end, :pointer,
		       :progress,  :pointer
	end

	attach_function :arena_create,
	                :hyperdex_ds_arena_create,
	                [],
	                :pointer
	attach_function :arena_destroy,
	                :hyperdex_ds_arena_destroy,
	                [:pointer],
	                :void

	attach_function :iterator_init,
	                :hyperdex_ds_iterator_init,
	                [:pointer, :hyperdatatype, :pointer, :size_t],
	                :void

	%w{list set}.each do |dtype|
		%w{string int float}.each do |vtype|
			attach_function "iterate_#{dtype}_#{vtype}_next",
			                "hyperdex_ds_iterate_#{dtype}_#{vtype}_next",
			                Array.new(vtype == "string" ? 3 : 2, :pointer),
			                :int
		end
	end

	%w{int string float}.each do |v1|
		%w{int string float}.each do |v2|
			arg_count = 1 +   # iterator
			            (v1 == "string" ? 2 : 1) +
			            (v2 == "string" ? 2 : 1)

			attach_function "iterate_map_#{v1}_#{v2}_next",
			                "hyperdex_ds_iterate_map_#{v1}_#{v2}_next",
			                Array.new(arg_count, :pointer),
			                :int
		end
	end

	attach_function :unpack_int,
	                :hyperdex_ds_unpack_int,
	                [:pointer, :size_t, :pointer],
	                :int
	attach_function :unpack_float,
	                :hyperdex_ds_unpack_float,
	                [:pointer, :size_t, :pointer],
	                :int
end
