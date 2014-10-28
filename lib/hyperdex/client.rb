require 'ffi'
require 'ffi/monkey_patches'
require 'ffi/tools/const_generator'

module HyperDex::Client
	def self.encode_attributes(attrs, attrs_size)
		(0..attrs_size-1).inject({}) do |h, i|
			attr = Attribute.new(attrs[i*Attribute.size])
			k = attr[:name].read_string.to_sym
			h.tap { |h|	h[k] = build_attribute(attr) }
		end
	end

	def self.build_attribute(attr)
		type = attr[:datatype]
		value = attr[:value].read_string(attr[:value_sz])

		case type
		when :STRING
			value

		when :INT64
			i = ::FFI::MemoryPointer.new(:int64_t)
			if HyperDex::FFI::DS.unpack_int(attr[:value], attr[:value_sz], i) < 0
				raise HyperDex::Client::HyperDexClientException.new(
				        HyperDex::Client::SERVERERROR,
				        "server sent malformed int attribute (#{value.inspect})"
				      )
			end

			i.read_int64

		when :FLOAT
			d = ::FFI::MemoryPointer.new(:double)
			if HyperDex::FFI::DS.unpack_float(attr[:value], attr[:value_sz], d) < 0
				raise HyperDex::Client::HyperDexClientException.new(
				        HyperDex::Client::SERVERERROR,
				        "server sent malformed float attribute (#{value.inspect})"
				      )
			end

			d.read_double

		when :DOCUMENT
			begin
				JSON.parse(value)
			rescue JSON::ParserError
				raise HyperDex::Client::HyperDexClientException.new(
				        HyperDex::Client::SERVERERROR,
				        "server sent malformed attribute(document)"
				      )
			end

		when :LIST_STRING
			iter = HyperDex.init_ds_iterator(type, value)
			ptr = ::FFI::MemoryPointer.new(:pointer)
			len = ::FFI::MemoryPointer.new(:size_t)

			res = []
			while (result = HyperDex::FFI::DS.iterate_list_string_next(iter, ptr, len)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed list(string)"
					      )
				end

				str = ptr.read_pointer
				res << (str.null? ? nil : str.read_string(len.read_size_t))
			end

			res

		when :LIST_INT64
			iter = HyperDex.init_ds_iterator(type, value)
			int = ::FFI::MemoryPointer.new(:int64_t)

			res = []
			while (result = HyperDex::FFI::DS.iterate_list_int_next(iter, int)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed list(int)"
					      )
				end

				res << int.read_int64
			end

			res

		when :LIST_FLOAT
			iter = HyperDex.init_ds_iterator(type, value)
			dbl = ::FFI::MemoryPointer.new(:double)

			res = []
			while (result = HyperDex::FFI::DS.iterate_list_float_next(iter, dbl)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed list(float)"
					      )
				end

				res << dbl.read_double
			end

			res

		when :SET_STRING
			iter = HyperDex.init_ds_iterator(type, value)
			ptr = ::FFI::MemoryPointer.new(:pointer)
			len = ::FFI::MemoryPointer.new(:size_t)

			res = Set.new
			while (result = HyperDex::FFI::DS.iterate_set_string_next(iter, ptr, len)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed set(string)"
					      )
				end

				str = ptr.read_pointer
				res << (str.null? ? nil : str.read_string(len.read_size_t))
			end

			res

		when :SET_INT64
			iter = HyperDex.init_ds_iterator(type, value)
			int = ::FFI::MemoryPointer.new(:int64_t)

			res = Set.new
			while (result = HyperDex::FFI::DS.iterate_set_int_next(iter, int)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed set(int)"
					      )
				end

				res << int.read_int64
			end

			res

		when :SET_FLOAT
			iter = HyperDex.init_ds_iterator(type, value)
			dbl = ::FFI::MemoryPointer.new(:double)

			res = Set.new
			while (result = HyperDex::FFI::DS.iterate_set_float_next(iter, dbl)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed set(float)"
					      )
				end

				res << dbl.read_double
			end

			res

		when :MAP_STRING_STRING
			iter = HyperDex.init_ds_iterator(type, value)
			kptr = ::FFI::MemoryPointer.new(:pointer)
			klen = ::FFI::MemoryPointer.new(:size_t)
			vptr = ::FFI::MemoryPointer.new(:pointer)
			vlen = ::FFI::MemoryPointer.new(:size_t)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_string_string_next(iter, kptr, klen, vptr, vlen)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(string, string)"
					      )
				end

				kstr = kptr.read_pointer
				kstr = (kstr.null? ? nil : kstr.read_string(klen.read_size_t))
				vstr = vptr.read_pointer
				vstr = (vstr.null? ? nil : vstr.read_string(vlen.read_size_t))
				res[kstr] = vstr
			end

			res

		when :MAP_STRING_INT64
			iter = HyperDex.init_ds_iterator(type, value)
			kptr = ::FFI::MemoryPointer.new(:pointer)
			klen = ::FFI::MemoryPointer.new(:size_t)
			vint = ::FFI::MemoryPointer.new(:int64_t)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_string_int_next(iter, kptr, klen, vint)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(string, int)"
					      )
				end

				kstr = kptr.read_pointer
				kstr = (kstr.null? ? nil : kstr.read_string(klen.read_size_t))
				res[kstr] = vint.read_int64
			end

			res

		when :MAP_STRING_FLOAT
			iter = HyperDex.init_ds_iterator(type, value)
			kptr = ::FFI::MemoryPointer.new(:pointer)
			klen = ::FFI::MemoryPointer.new(:size_t)
			vdbl = ::FFI::MemoryPointer.new(:double)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_string_float_next(iter, kptr, klen, vdbl)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(string, float)"
					      )
				end

				kstr = kptr.read_pointer
				kstr = (kstr.null? ? nil : kstr.read_string(klen.read_size_t))
				res[kstr] = vdbl.read_double
			end

			res

		when :MAP_INT64_STRING
			iter = HyperDex.init_ds_iterator(type, value)
			kint = ::FFI::MemoryPointer.new(:int64_t)
			vptr = ::FFI::MemoryPointer.new(:pointer)
			vlen = ::FFI::MemoryPointer.new(:size_t)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_int_string_next(iter, kint, vptr, vlen)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(int, string)"
					      )
				end

				vstr = vptr.read_pointer
				vstr = (vstr.null? ? nil : vstr.read_string(vlen.read_size_t))
				res[kint.read_int64] = vstr
			end

			res

		when :MAP_INT64_INT64
			iter = HyperDex.init_ds_iterator(type, value)
			kint = ::FFI::MemoryPointer.new(:int64_t)
			vint = ::FFI::MemoryPointer.new(:int64_t)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_int_int_next(iter, kint, vint)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(int, int)"
					      )
				end

				res[kint.read_int64] = vint.read_int64
			end

			res

		when :MAP_INT64_FLOAT
			iter = HyperDex.init_ds_iterator(type, value)
			kint = ::FFI::MemoryPointer.new(:int64_t)
			vdbl = ::FFI::MemoryPointer.new(:double)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_int_float_next(iter, kint, vdbl)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(int, float)"
					      )
				end

				res[kint.read_int64] = vdbl.read_double
			end

			res

		when :MAP_FLOAT_STRING
			iter = HyperDex.init_ds_iterator(type, value)
			kdbl = ::FFI::MemoryPointer.new(:double)
			vptr = ::FFI::MemoryPointer.new(:pointer)
			vlen = ::FFI::MemoryPointer.new(:size_t)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_float_string_next(iter, kdbl, vptr, vlen)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(float, string)"
					      )
				end

				vstr = vptr.read_pointer
				vstr = (vstr.null? ? nil : vstr.read_string(vlen.read_size_t))
				res[kdbl.read_double] = vstr
			end

			res

		when :MAP_FLOAT_INT64
			iter = HyperDex.init_ds_iterator(type, value)
			kdbl = ::FFI::MemoryPointer.new(:double)
			vint = ::FFI::MemoryPointer.new(:int64_t)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_float_int_next(iter, kdbl, vint)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(float, int)"
					      )
				end

				res[kdbl.read_double] = vint.read_int64
			end

			res

		when :MAP_FLOAT_FLOAT
			iter = HyperDex.init_ds_iterator(type, value)
			kdbl = ::FFI::MemoryPointer.new(:double)
			vdbl = ::FFI::MemoryPointer.new(:double)

			res = {}
			while (result = HyperDex::FFI::DS.iterate_map_float_float_next(iter, kdbl, vdbl)) > 0
				if result < 0
					raise HyperDex::Client::HyperDexClientException.new(
					        HyperDex::Client::SERVERERROR,
					        "server sent malformed map(int, float)"
					      )
				end

				res[kdbl.read_double] = vdbl.read_double
			end

			res

		else
			raise HyperDex::Client::HyperDexClientException.new(
			        HyperDex::Client::SERVERERROR,
			        "server sent malformed attributes"
			      )
		end
	end

	HyperDex::FFI::Client.enum_type(:hyperdex_client_returncode).set_consts(self)

	class Attribute < ::FFI::Struct
		layout :name,     :pointer,
		       :value,    :pointer,
		       :value_sz, :size_t,
		       :datatype, HyperDex::FFI::DS.enum_type(:hyperdatatype)
	end
end

require_relative 'client/client'
require_relative 'client/deferred'
require_relative 'client/hyperdex_client_exception'
require_relative 'client/iterator'
require_relative 'client/response'
