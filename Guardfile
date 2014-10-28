guard 'spork', :rspec_port => 12031 do
  watch('Gemfile')             { :rspec }
  watch('Gemfile.lock')        { :rspec }
  watch('spec/spec_helper.rb') { :rspec }
end

guard 'rspec',
      :cmd            => "rspec --drb --drb-port 12031",
      :all_on_start   => true,
      :all_after_pass => true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/})               { "spec" }
end

guard :shell do
	watch('ext/extconf.rb')   { Dir.chdir('ext') { `ruby extconf.rb` } }
	watch('ext/Makefile')     { Dir.chdir('ext') { `make` } }
	watch(%r{^ext/[^/.]+\.c$}) { Dir.chdir('ext') { `make` } }
end
