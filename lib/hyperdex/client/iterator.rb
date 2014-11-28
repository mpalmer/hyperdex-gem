require_relative 'response'

class HyperDex::Client::Iterator < HyperDex::Client::Response
	def initialize(c)
		super
		@backlog = []
	end

	def callback
		if status == HyperDex::Client::SEARCHDONE
			super
		elsif status == HyperDex::Client::SUCCESS
			@backlog << encode_return
		else
			@backlog << HyperDex::Client::exception(status, @client.error_message)
		end
	end

	def has_next?
		@client.loop until @finished or !@backlog.empty?
		!@backlog.empty?
	end
	alias_method :has_next, :has_next?

	def next
		@backlog.shift
	end
end
