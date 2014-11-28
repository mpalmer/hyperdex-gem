module HyperDex::Client
	class Exception < StandardError
		@status = HyperDex::Client::EXCEPTION

		def status
			self.class.status
		end

		def self.status
			self.class.instance_variable_get(:@status)
		end

		def symbol
			HyperDex::FFI::Client.
			  hyperdex_client_returncode_to_string(status).
			  read_string
		end
	end

	HyperDexClientException = Exception

	class UnknownSpaceError < Exception
		@status = HyperDex::Client::UNKNOWNSPACE
	end

	class CoordFailError < Exception
		@status = HyperDex::Client::COORDFAIL
	end

	class ServerError < Exception
		@status = HyperDex::Client::SERVERERROR
	end

	class PollFailedError < Exception
		@status = HyperDex::Client::POLLFAILED
	end

	class OverflowError < Exception
		@status = HyperDex::Client::OVERFLOW
	end

	class ReconfigureError < Exception
		@status = HyperDex::Client::RECONFIGURE
	end

	class TimeoutError < Exception
		@status = HyperDex::Client::TIMEOUT
	end

	class UnknownAttrError < Exception
		@status = HyperDex::Client::UNKNOWNATTR
	end

	class DupeAttrError < Exception
		@status = HyperDex::Client::DUPEATTR
	end

	class NonePendingError < Exception
		@status = HyperDex::Client::NONEPENDING
	end

	class DontUseKeyError < Exception
		@status = HyperDex::Client::DONTUSEKEY
	end

	class WrongTypeError < Exception
		@status = HyperDex::Client::WRONGTYPE
	end

	class NoMemError < Exception
		@status = HyperDex::Client::NOMEM
	end

	class InterruptedError < Exception
		@status = HyperDex::Client::INTERRUPTED
	end

	class ClusterJumpError < Exception
		@status = HyperDex::Client::CLUSTER_JUMP
	end

	class OfflineError < Exception
		@status = HyperDex::Client::OFFLINE
	end

	class InternalError < Exception
		@status = HyperDex::Client::INTERNAL
	end

	class GarbageError < Exception
		@status = HyperDex::Client::GARBAGE
	end

	EXCEPTION_STATUS_MAP = ObjectSpace.each_object(Class).reduce({}) do |h, ex|
		if ex.ancestors.include?(::HyperDex::Client::Exception)
			h[ex.status] = ex
		end
		h
	end

	def self.exception(status, message)
		klass = EXCEPTION_STATUS_MAP[status]
		if klass.nil?
			klass = HyperDex::Client::Exception
		end

		klass.new(message)
	end
end
