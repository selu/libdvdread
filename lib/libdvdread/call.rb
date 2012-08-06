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
		# TODO dvd_file functions

		attach_function :ifo_open, :ifoOpen, [ :pointer, :int ], :pointer
		attach_function :ifo_open_vmgi, :ifoOpenVMGI, [ :pointer ], :pointer
		attach_function :ifo_open_vtsi, :ifoOpenVTSI, [ :pointer, :int ], :pointer
		attach_function :ifo_close, :ifoClose, [ :pointer ], :void
    # TODO ifo_read and ifo_free functions


	end
end
