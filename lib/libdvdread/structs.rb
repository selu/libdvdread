require 'ffi'

module LIBDVDREAD

  module GetStruct
    def get_struct(ary,klass)
      @sary ||= Hash.new
      @sary[ary] ||= self[ary].null? ? false : klass.new(self[ary])
      @sary[ary].is_a?(FalseClass) ? nil : @sary[ary]
    end    
  end

  module LangCode
    def lang_code
      [self[:lang_code]/256,self[:lang_code]&0xff].map{|c| c.chr}.join
    end
  end
  
  class DvdTimeT < FFI::Struct
		layout :hour, :uint8,
			:minute, :uint8,
			:second, :uint8,
			:frame_u, :uint8
      
    FRAMES_PER_S = [-1.0, 25.00, -1.0, 29.97]
    
    def fps
      FRAMES_PER_S[(self[:frame_u]>>6)]
    end
    
    def hour
      bcd_to_i(self[:hour])
    end
    
    def minute
      bcd_to_i(self[:minute])
    end
    
    def second
      bcd_to_i(self[:second])
    end
    
    def usec
      bcd_to_i(self[:frame_u]&0x3f)*1000.0/fps
    end
    
    def bcd_to_i(bcd)
      (bcd>>4)*10 + (bcd & 0x0f)
    end
	end

	class VideoAttrT < FFI::Struct
		layout :bitmap1, :uint8, :bitmap2, :uint8
    
    def mpeg_version
      self[:bitmap1] & 3
    end
    
    def video_format
      (self[:bitmap1]>>2) & 3
    end
    
    def display_aspect_ratio
      (self[:bitmap1]>>4) & 3
    end
    
    def permitted_df
      self[:bitmap1]>>6
    end
    
    def line21_cc_1
      self[:bitmap2] & 1
    end
    
    def line21_cc_2
      (self[:bitmap2]>>1) & 1
    end
    
    def bitrate
      (self[:bitmap2]>>3) & 1
    end
    
    def picture_size
      (self[:bitmap2]>>4) & 3
    end
    
    def letterboxed
      (self[:bitmap2]>>6) & 1
    end
    
    def film_mode
      self[:bitmap2]>>7
    end
	end

	class AudioAttrT < FFI::Struct
    include LangCode
    
		layout :bitmap1, :uint8, :bitmap2, :uint8,
			:lang_code, :uint16,
			:lang_extension, :uint8,
			:code_extension, :uint8,
			:unknown1, :uint8,
			:bitmap3, :uint8
      
    def audio_format
      self[:bitmap1] & 7
    end
    
    def multichannel_extension
      (self[:bitmap1]>>3) & 1
    end
    
    def lang_type
      (self[:bitmap1]>>4) & 2
    end
    
    def application_mode
      self[:bitmap1]>>6
    end	
    
    def quantization
      self[:bitmap2] & 3
    end
    
    def sample_frequency
      (self[:bitmap2]>>2) & 3
    end
    
    def channels
      self[:bitmap2]>>5
    end
    
    def channel_assignment
      (self[:bitmap3]>>1) & 7
    end
    
    def version
      (self[:bitmap3]>>4) & 3
    end
    
    def mc_intro
      (self[:bitmap3]>>6) & 1
    end
    
    def mode
      self[:bitmap3]>>7
    end
    
    def dolby_encoded
      (self[:bimtap]>>4) & 1
    end
  end

	class MultichannelExtT < FFI::Struct
		layout :bitmap1, :uchar,
			:bitmap2, :uchar,
			:bitmap3, :uchar,
			:bitmap4, :uchar,
			:bitmap5, :uchar,
			:zero, [:uint8, 19]
	end

	class SubpAttrT < FFI::Struct
    include LangCode
    
		layout :bitmap, :uchar, :zero, :uint8,
			:lang_code, :uint16,
			:lang_extension, :uint8,
			:code_extension, :uint8
      
    def code_mode
      self[:bitmap] & 7
    end
    
    def type
      self[:bitmap]>>6
    end
	end

	class TitleInfoT < FFI::Struct
	  layout :bitmap, :uchar,
	  	:nr_of_angles, :uint8,
	  	:nr_of_ptts, :uint16,
	  	:parental_id, :uint16,
	  	:title_set_nr, :uint8,
	  	:vts_ttn, :uint8,
	  	:title_set_sector, :uint32
	end

	class TtSrptT < FFI::Struct
		layout :nr_of_srpts, :uint16,
			:zero1, :uint16,
			:last_byte, :uint32,
			:title, :pointer

      def title(idx)
        return nil if idx < 1 || idx > self[:nr_of_srpts]
        @srpt_ary ||= Array.new
        @srpt_ary[idx-1] ||= TitleInfoT.new(self[:title]+(idx-1)*TitleInfoT.size)
      end
      
      def nr_of_srpts
        self[:nr_of_srpts]
      end
	end

	class PgcT < FFI::Struct
		pack 1
		layout :zero1, :uint16,
			:nr_of_programs, :uint8,
			:nr_of_cells, :uint8,
			:playback_time, DvdTimeT,
			:prohibited_ops, :uint32,
			:audio_control, [:uint16, 8],
			:subp_control, [:uint32, 32],
			:next_pgc_nr, :uint16,
			:prev_pgc_nr, :uint16,
			:goup_pgc_nr, :uint16,
			:still_time, :uint8,
			:pg_playback_mode, :uint8,
			:palette, [:uint32, 16],
			:command_tbl_offset, :uint16,
			:program_map_offset, :uint16,
			:cell_playback_offset, :uint16,
			:cell_position_offset, :uint16,
			:command_tbl, :pointer,
			:program_map, :pointer,
			:cell_playback, :pointer,
			:cell_position, :pointer
	end

	class PgciSrpT < FFI::Struct
    include GetStruct
    
		layout :entry_id, :uint8,
			:bitmap, :uint8,
			:ptl_id_mask, :uint16,
			:pgc_start_byte, :uint32,
			:pgc, :pointer
      
    def pgc
      get_struct(:pgc,PgcT)
    end
	end

	class PgcitT < FFI::Struct
	  layout :nr_of_pgci_srp, :uint16,
	  	:zero1, :uint16,
	  	:last_byte, :uint32,
	  	:pgci_srp, :pointer
      
      def pgci_srp(idx)
        return nil if idx < 1 || idx > self[:nr_of_pgci_srp]
        @pgci_srp_ary ||= Array.new
        @pgci_srp_ary[idx-1] ||= PgciSrpT.new(self[:pgci_srp]+(idx-1)*PgciSrpT.size)
      end
	end

  class VtsAtrtT < FFI::Struct
    layout :nr_of_vtss, :uint16,
      :zero1, :uint16,
      :last_byte, :uint32,
      :vts, :pointer,
      :vts_atrt_offset, :uint32
      
      def nr_of_vtss
        self[:nr_of_vtss]
      end
      
      def vts_atrt_offset
        self[:vts_atrt_offset]
      end
  end
  
	class VmgiMatT < FFI::Struct
    pack 1
		layout :vmg_identifier, [:char, 12],
			:vmg_last_sector, :uint32,
			:zero1, [:uint8, 12],
			:vmgi_last_sector, :uint32,
			:zero2, :uint8,
			:specification_version, :uint8,
			:vmg_category, :uint32,
			:vmg_nr_of_volumes, :uint16,
			:vmg_this_volume_nr, :uint16,
			:disc_side, :uint8,
			:zero3, [:uint8, 19],
			:vmg_nr_of_title_sets, :uint16,
			:provider_identifier, [:char, 32],
			:vmg_pos_code, :uint64,
			:zero4, [:uint8, 24],
			:vmgi_last_byte, :uint32,
			:first_play_pgc, :uint32,
			:zero5, [:uint8, 56],
			:vmgm_vobs, :uint32,
			:tt_srpt, :uint32,
			:vmgi_pgci_ut, :uint32,
			:ptl_mait, :uint32,
			:vts_atrt, :uint32,
			:txtdt_mgi, :uint32,
			:vmgm_c_adt, :uint32,
			:vmgm_vobu_admap, :uint32,
			:zero6, [:uint8, 32],
			:vmgm_video_attr, VideoAttrT,
			:zero7, :uint8,
			:nr_of_vmgm_audio_streams, :uint8,
			:vmgm_audio_attr, AudioAttrT,
			:zero8, [AudioAttrT, 7],
			:zero9, [:uint8, 17],
			:nr_of_vmgm_subp_streams, :uint8,
			:vmgm_subp_attr, SubpAttrT,
			:zero10, [SubpAttrT, 27]
	end

	class VtsiMatT < FFI::Struct
		pack 1
		layout :vts_identifier, [:char, 12],
			:vts_last_sector, :uint32,
			:zero1, [:uint8, 12],
			:vtsi_last_sector, :uint32,
			:zero2, :uint8,
			:specification_version, :uint8,
			:vts_category, :uint32,
			:zero3, [:uint8, 90],
			:vtsi_last_byte, :uint32,
			:zero4, [:uint8, 60],
			:vtsm_vobs, :uint32,
			:vtstt_vobs, :uint32,
			:vts_ptt_srpt, :uint32,
			:vts_pgcit, :uint32,
			:vtsm_pgci_ut, :uint32,
			:vts_tmapt, :uint32,
			:vtsm_c_adt, :uint32,
			:vtsm_vobu_admap, :uint32,
			:vts_c_adt, :uint32,
			:vts_vobu_admap, :uint32,
			:zero5, [:uint8, 24],
			:vtsm_video_attr, VideoAttrT,
			:zero6, :uint8,
			:nr_of_vtsm_audio_streams, :uint8,
			:vtsm_audio_attr, AudioAttrT,
			:zero7, [AudioAttrT, 7],
			:zero8, [:uint8, 17],
			:nr_of_vtsm_subp_streams, :uint8,
			:vtsm_subp_streams, SubpAttrT,
			:zero9, [SubpAttrT, 27],
			:zero10, [:uint8, 2],
			:vts_video_attr, VideoAttrT,
			:zero11, :uint8,
			:nr_of_vts_audio_streams, :uint8,
			:vts_audio_attr, [AudioAttrT, 8],
			:zero12, [:uint8, 17],
			:nr_of_vts_subp_streams, :uint8,
			:vts_subp_attr, [SubpAttrT, 32],
			:zero13, :uint16,
			:vts_mu_audio_attr, [MultichannelExtT, 8]
	end

  class IfoHandleT < FFI::ManagedStruct
    include GetStruct
    
    layout :dvd_file, :pointer,
      # VMGI
      :vmgi_mat, :pointer,
      :tt_srpt, :pointer,
      :first_play_pgc, :pointer,
      :ptl_mait, :pointer,
      :vts_atrt, :pointer,
      :txtdt_mgi, :pointer,
      # Common
      :pgci_ut, :pointer,
      :menu_c_adt, :pointer,
      :menu_vobu_admap, :pointer,
      # VTSI
      :vtsi_mat, :pointer,
      :vts_ptt_srpt, :pointer,
      :vts_pgcit, :pointer,
      :vts_tmapt, :pointer,
      :vts_c_adt, :pointer,
      :vts_vobu_admap, :pointer
    
    def self.release(ptr)
      Call.ifo_close(ptr)
    end
    
    def vmgi_mat
      get_struct(:vmgi_mat,VmgiMatT)
    end
    
    def tt_srpt
      get_struct(:tt_srpt,TtSrptT)
    end
    
    def vts_atrt
      get_struct(:vts_atrt,VtsAtrtT)
    end
    
    def vtsi_mat
      get_struct(:vtsi_mat,VtsiMatT)
    end
    
    def vts_pgcit
      get_struct(:vts_pgcit,PgcitT)
    end
  end
end
