require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rubygems'

# Test
require 'rake/testtask'
desc 'Default: run unit tests.'
task :default => :test

Rake::TestTask.new(:test) do |test|
	test.test_files = FileList.new('test/test_*.rb')
	test.libs << 'test'
	test.verbose = true
end

# Yard
begin
	require 'yard'
	YARD::Rake::YardocTask.new
rescue LoadError
	task :yardoc do
		abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
	end
end

desc "Alias for 'rake yard'"
task :doc => :yard
