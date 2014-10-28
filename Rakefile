require 'rubygems'
require 'bundler'

task :default => :test

begin
	Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
	$stderr.puts e.message
	$stderr.puts "Run `bundle install` to install missing gems"
	exit e.status_code
end

Bundler::GemHelper.install_tasks

task :release do
	sh "git release"
end

require 'yard'

YARD::Rake::YardocTask.new :doc do |yardoc|
	yardoc.files = ["README.md", "lib/**/*.rb"]
end

desc "Run guard"
task :guard do
	require 'guard'
	::Guard.start(:debug => true)
	while ::Guard.running do
		sleep 0.5
	end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :test do |t|
	t.pattern = "spec/**/*_spec.rb"
end

task :compile => 'ext/Makefile' do
	Dir.chdir(File.expand_path('../ext', __FILE__)) do
		sh "make"
	end
end
