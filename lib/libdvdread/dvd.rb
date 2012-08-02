require 'libdvdread/call'

module LIBDVDREAD
	class Dvd
		def initialize(path='/dev/dvd')
			@dvd_reader = Call.dvd_open(path)
			@path = path
			if block_given?
				begin
				  yield self
				ensure
					self.close
				end
			end
		end

		def close
			unless @dvd_reader.nil?
			  Call.dvd_close(@dvd_reader)
			  @dvd_reader = nil
			end
		end

		def disc_id
		end
	end
end
