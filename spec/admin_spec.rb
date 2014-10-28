require_relative 'spec_helper'

describe HyperDex::Admin::Client do
	# You don't need a hyperdex server running on any of these locations,
	# because no connection is attempted until you try to actually *do*
	# anything with the connection.
	context ".new" do
		it "accepts a hostname and port" do
			a = HyperDex::Admin::Client.new('host.name.example.com', 12345)
			expect(a.host).to eq('host.name.example.com')
			expect(a.port).to eq(12345)
		end
		
		it "accepts just a hostname" do
			a = HyperDex::Admin::Client.new('some.host.example.com')
			expect(a.host).to eq('some.host.example.com')
			expect(a.port).to eq(1982)
		end

		it "accepts no args" do
			a = HyperDex::Admin::Client.new
			expect(a.host).to eq('localhost')
			expect(a.port).to eq(1982)
		end
	end

	context "#list_spaces" do
		let(:a) do
			HyperDex::Admin::Client.new(
			  ENV['HYPERDEX_TEST_SERVER'] || 'localhost',
			  ENV['HYPERDEX_TEST_SERVER_PORT'] || 1982
			)
		end
		
		let(:spaces) { a.list_spaces }

		it "returns an array" do
			expect(spaces).to be_an(Array)
		end

		it "returns symbols" do
			spaces.each do |s|
				expect(s).to be_a(Symbol)
			end
		end

		it "contains the pre-existing test space" do
			clean_space
			expect(spaces).to include(:test)
		end
	end
end
