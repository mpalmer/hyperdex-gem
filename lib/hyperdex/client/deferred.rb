require_relative 'response'

class HyperDex::Client::Deferred < HyperDex::Client::Response
	def wait
		@client.loop until @finished or @reqid.nil?
		encode_return
	end
end
