class HyperDex::Admin::Client
	attr_reader :host, :port

	def initialize(host = 'localhost', port = 1982)
		@host = host
		@port = port
		@client = ::FFI::AutoPointer.new(
		              HyperDex::FFI::Admin.create(
		                ::FFI::MemoryPointer.from_string(host),
		                port
		              ),
		              proc { |p| HyperDex::FFI::Admin.destroy(p) }
		            )
	end

	def list_spaces
		ptr = ::FFI::MemoryPointer.new(:pointer)

		make_request(:list_spaces, :rc, ptr)

		ptr.read_pointer.read_string.split("\n").map { |s| s.to_sym }
	end

	def add_space(definition)
		make_request(
		  :add_space,
		  ::FFI::MemoryPointer.from_string(definition.to_s),
		  :rc
		)
	end

	def rm_space(name)
		make_request(
		  :rm_space,
		  ::FFI::MemoryPointer.from_string(name.to_s),
		  :rc
		)
	end

	private
	def make_request(f, *args)
		rc = ::FFI::MemoryPointer.new(:int)

		# Sigh... not all functions have the returncode as the last arg, so we
		# need to specify where the rc parameter is in the arg list with this
		# special symbol.
		args.map! { |e| (:rc == e) ? rc : e }
		reqid = HyperDex::FFI::Admin.__send__(f, @client, *args)

		if reqid < 0
			raise HyperDex::Admin::Exception.new(rc.read_int, "hyperdex_admin_#{f} failed")
		end

		wait_for_response(reqid)
	end

	def wait_for_response(reqid)
		rc = ::FFI::MemoryPointer.new(:int)

		if (ri = HyperDex::FFI::Admin.loop(@client, -1, rc)) != reqid
			raise HyperDex::Admin::Exception.new(
			        HyperDex::Admin::EXCEPTION,
			        "CAN'T HAPPEN: hyperdex_admin_loop() returned an unknown reqid (expected #{reqid}, got #{ri})"
			      )
		end

		if ri < 0
			raise HyperDex::Admin::Exception.new(rc.read_int, "hyperdex_admin_loop failed")
		end
	end
end
