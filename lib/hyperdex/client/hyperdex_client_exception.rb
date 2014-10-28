class HyperDex::Client::HyperDexClientException
	attr_accessor :status, :symbol

	def initialize(status, message)
		super(message)
		@status = status
		@symbol = HyperDex::FFI::Client.hyperdex_client_returncode_to_string(status).read_string
	end
end
