require 'rubygems'
require 'ffi'

module LIBDVDREAD
	module Call
		extend FFI::Library
		ffi_lib ['dvdread', 'libdvdread.so.4']

		attach_function :dvd_open, :DVDOpen, [ :string ], :pointer
		attach_function :dvd_close, :DVDClose, [ :pointer ], :void
		attach_function :dvd_disc_id, :DVDDiscID, [ :pointer, :pointer ], :int
		attach_function :dvd_udf_volume_info, :DVDUDFVolumeInfo, [ :pointer, :pointer, :uint, :pointer, :uint ], :int
		attach_function :dvd_iso_volume_info, :DVDISOVolumeInfo, [ :pointer, :pointer, :uint, :pointer, :uint ], :int
	end
end
