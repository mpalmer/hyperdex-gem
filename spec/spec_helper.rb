require 'spork'

Spork.prefork do
	require 'bundler'
	Bundler.setup(:default, :test)
	require 'rspec/core'
	require 'rspec/mocks'

	require 'pry'

	module HyperDexConnections
		def admin_conn
			@admin_conn ||= HyperDex::Admin::Client.new(
			                  ENV['HYPERDEX_TEST_SERVER'] || 'localhost',
			                  ENV['HYPERDEX_TEST_SERVER_PORT'] || 1982
			                )
		end

		def client_conn
			@client_conn ||= HyperDex::Client::Client.new(
			                   ENV['HYPERDEX_TEST_SERVER'] || 'localhost',
			                   ENV['HYPERDEX_TEST_SERVER_PORT'] || 1982
			                 )
		end
	end

	module GlobalLets
		extend RSpec::SharedContext

		# Yes, this is appallingly bad practice, but unfortunately I don't
		# have a lot of other ideas on how to better make sure I've got a
		# "clean" hyperdex data environment to run tests in.
		let(:clean_space) do
			admin_conn.list_spaces.each do |s|
				admin_conn.rm_space(s)
			end
			
			admin_conn.add_space(<<-EOF)
				space test
				key id
				attributes data, int timestamp
			EOF

			10.times do |i|
				client_conn.put(
				  :test,
				  i,
				  :data => "Test data element #{i}",
				  :timestamp => Time.at(1414894369+i).to_i
				)
			end
		end
	end

	RSpec.configure do |config|
		config.fail_fast = true
#		config.full_backtrace = true

		config.expect_with :rspec do |c|
			c.syntax = :expect
		end

		config.include HyperDexConnections
		config.include GlobalLets
	end
end

Spork.each_run do
	require 'hyperdex'
end
