require 'ffi'

class HyperDex::Client::Response
	def initialize(c)
		@client = c
		@reqid = nil
		@finished = false

		@status_ptr = ::FFI::MemoryPointer.new(:int)
		@status_ptr.put_int32(0, HyperDex::Client::GARBAGE)
		@status = false

		@attrs_ptr = ::FFI::MemoryPointer.new(:pointer)
		@attrs_ptr.put_pointer(0, ::FFI::Pointer::NULL)
		@attrs_sz_ptr = ::FFI::MemoryPointer.new(:size_t)
		@attrs_sz_ptr.put_int64(0, 0)
		@attrs = false

		@description_ptr = ::FFI::MemoryPointer.new(:pointer)
		@description_ptr.put_pointer(0, ::FFI::Pointer::NULL)
		@description = false

		@count_ptr = ::FFI::MemoryPointer.new(:size_t)
		@count_ptr.put_int64(0, 0)
		@count = false

		@arena_ptr = ::FFI::AutoPointer.new(
		               HyperDex::FFI::DS.arena_create(),
		               proc { |p| HyperDex::FFI::DS.arena_destroy(p) }
		             )
	end

	def callback
		@finished = 1
		@client.delete_op(@reqid)
	end

	def status
		@status_ptr.read_int32
	end

	private
	def encode_return
		case status
		when HyperDex::Client::SUCCESS
			if @description
				@description_ptr.read_string
			elsif @count
				@count_ptr.read_int64
			elsif @attrs
				ptr = @attrs_ptr.read_pointer
				sz  = @attrs_sz_ptr.read_int64
				HyperDex::Client.encode_attributes(ptr, sz).tap do
					HyperDex::FFI::Client.hyperdex_client_destroy_attrs(ptr, sz)
				end
			else
				true
			end
		when HyperDex::Client::NOTFOUND
			nil
		when HyperDex::Client::CMPFAIL
			false
		else
			raise HyperDex::Client.exception(status, @client.error_message)
		end
	end
end
