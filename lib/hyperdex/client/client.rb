class HyperDex::Client::Client
	def initialize(host = 'localhost', port = 1982)
		@client = ::FFI::AutoPointer.new(
		              HyperDex::FFI::Client.hyperdex_client_create(host, port),
		              proc { |p| HyperDex::FFI::Client.hyperdex_client_destroy(p) }
		            )
		if @client.null?
			raise SystemCallError,
			      "Could not create HyperDex::Client instance"
		end

		@ops = {}
	end

	def loop(timeout = -1)
		rc = ::FFI::MemoryPointer.new(HyperDex::FFI::Client.enum_type(:hyperdex_client_returncode).native_type)
		while (ret = HyperDex::FFI::Client.hyperdex_client_loop(@client, timeout, rc)) < 0
			if rc.read_int32 != HyperDex::Client::INTERRUPTED
				raise HyperDex::Client::HyperDexClientException.new(
				        rc.read_int32,
				        self.error_message
				      )
			end
		end

		@ops[ret].tap { |op| op.callback }
	end

	def poll_fd
		if (fd = HyperDex::FFI::Client.hyperdex_client_poll(@client)) < 0
			raise HyperDex::Client::HyperDexClientException.new(
			        HyperDex::Client::EXCEPTION,
			        "CAN'T HAPPEN: hyperdex_client_poll failed!"
			      )
		end

		fd
	end

	def error_message
		HyperDex::FFI::Client.hyperdex_client_error_message(@client).read_string
	end

	def delete_op(reqid)
		@ops.delete(reqid)
	end
end
