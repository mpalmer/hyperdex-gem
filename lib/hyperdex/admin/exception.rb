class HyperDex::Admin::Exception < StandardError
	attr_reader :status, :detail

	def initialize(rc, detail)
		@status = rc
		@detail = detail

		rc_string = HyperDex::FFI::Admin.returncode_to_string(rc).read_string
		super("#{rc_string} (#{rc}): #{detail}")
	end
end
