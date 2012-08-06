require 'libdvdread/call'
require 'libdvdread/title'

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
			if @disc_id.nil?
				data = FFI::MemoryPointer.new :uchar, 16
				LIBDVDREAD::Call.dvd_disc_id @dvd_reader, data   # TODO handle return value
				@disc_id = data.read_array_of_uchar(data.size).map{|byte| '%02x' % byte}.join
				data.free
			end
			@disc_id
		end

		def vol_id
			if @volid.nil?
				get_volume_info
			end
			@volid
		end

		def volset_id
			if @volsetid.nil?
				get_volume_info
			end
			@volsetid
		end

		def get_volume_info
			data1 = FFI::MemoryPointer.new :char, 32
			data2 = FFI::MemoryPointer.new :uchar, 128
			if LIBDVDREAD::Call.dvd_udf_volume_info(@dvd_reader, data1, data1.size, data2, data2.size) != 0
			  if LIBDVDREAD::Call.dvd_iso_volume_info(@dvd_reader, data1, data1.size, data2, data2.size) != 0
			  	nil # TODO handle error
				end
			end

			@volid = data1.read_string
			@volsetid = data2.read_string(data2.size)

			data2.free
			data1.free
		end

    def nr_of_titlesets
      ifo.vts_atrt.nr_of_vtss
    end
    
    def nr_of_titles
      ifo.tt_srpt.nr_of_srpts
    end
    
    def ifo(idx=0)
      return nil if idx < 0 || (idx > 0 && idx > nr_of_titlesets)
      @ifo_ary ||= Array.new
      @ifo_ary[idx] ||= IfoHandleT.new LIBDVDREAD::Call.ifo_open(@dvd_reader,idx)
    end
    
    def title(idx)
      return nil if idx < 1 || idx > nr_of_titles
      @titles ||= Array.new
      @titles[idx-1] ||= Title.new self,idx
    end
	end
end
