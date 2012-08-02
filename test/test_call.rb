require 'helper'

class TestCall < MiniTest::Unit::TestCase
	include AssertMethod

	def test_dvd_methods
		assert_method :dvd_open
		assert_method :dvd_close
	end
end
