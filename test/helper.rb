require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/wscolor'

require 'libdvdread'

module AssertMethod
	def assert_method(method)
		assert LIBDVDREAD::Call.respond_to?(method), "Call.#{method.to_s} is missing"
	end
end
