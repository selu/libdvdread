module LIBDVDREAD
  class Title
    AUDIO_FORMAT = %w(ac3 ? mpeg1 mpeg2 lpcm sdds dts)
    VIDEO_FORMAT = %w(NTSC PAL)
    ASPECT_RATIO = %w(4/3 16/9 "?/?" 16/9)
    VIDEO_HEIGHT = %w(480 576 ??? 576)
    VIDEO_WIDTH = %w(720 704 352 352)
    PERMITTED_DF = ["P&S + Letter", "Pan&Scan", "Letterbox", "?"]
    
    def initialize(dvd,index)
      @dvd = dvd
      @index = index
      # TODO error if index is out of range
      fill_info
    end
    
    def fill_info
      @title_info = @dvd.ifo.tt_srpt.title(@index)
      @ifo = @dvd.ifo(@title_info[:title_set_nr])
      @pgc = @ifo.vts_pgcit.pgci_srp(@title_info[:vts_ttn]).pgc

      vattr = @ifo.vtsi_mat[:vts_video_attr]
      
      @video = {}
      @video[:format] = VIDEO_FORMAT[vattr.video_format]
      @video[:aspect] = ASPECT_RATIO[vattr.display_aspect_ratio]
      @video[:width] = VIDEO_WIDTH[vattr.picture_size]
      @video[:height] = VIDEO_HEIGHT[vattr.video_format]
      @video[:df] = PERMITTED_DF[vattr.permitted_df]
      
      @audios = []
      (0..@ifo.vtsi_mat[:nr_of_vts_audio_streams]).each do |i|
        if (@pgc[:audio_control][i] & 0x8000) > 0
          audio = {:id => @pgc[:audio_control][i]>>8 & 7}
          attr = @ifo.vtsi_mat[:vts_audio_attr][i]
          case attr.audio_format
          when 0
            audio[:id] += 128
          when 6
            audio[:id] += 136
          when 2,3
            audio[:id] += 0 # 192 ???
          when 4
            audio[:id] += 160
          end
          audio[:lang_code] = attr.lang_code
          audio[:format] = AUDIO_FORMAT[attr.audio_format]
          audio[:channels] = attr.channels+1
          @audios << audio
        end
      end
      
      @subtitles = []
      (0..@ifo.vtsi_mat[:nr_of_vts_subp_streams]).each do |i|
        if (@pgc[:subp_control][i] & 0x80000000) > 0
          sub = {:id => @subtitles.length}
          attr = @ifo.vtsi_mat[:vts_subp_attr][i]
          sub[:lang_code] = attr.lang_code
          sub[:id] = @pgc[:subp_control][i]>>24 & 0x1f if vattr.display_aspect_ratio == 0
          sub[:id] = @pgc[:subp_control][i]>>8 & 0x1f if vattr.display_aspect_ratio == 3
          @subtitles << sub
        end
      end
    end
    
    def pgc
      @pgc
    end
    
    def ifo
      @ifo
    end
    
    def title_info
      @title_info
    end
    
    def playback_time
      @playback_time ||= @pgc[:playback_time]
      "%02d:%02d:%02d.%03d" % [@playback_time.hour, @playback_time.minute, @playback_time.second, @playback_time.usec]
    end
    
    def audio_streams
      @audios
    end
    
    def subtitle_streams
      @subtitles
    end
    
    def fps
      @playback_time ||= @pgc[:playback_time]
      @playback_time.fps
    end
    
    def nr_of_chapters
      #@title_info[:nr_of_ptts]
      @pgc[:nr_of_programs]
    end
    
    def nr_of_cells
      @pgc[:nr_of_cells]
    end
  end
end