require 'rubygems'
require 'net/http'
require 'json'

module XBMC_JSONRPC

  def self.new(options)
    @connection = XBMC_JSONRPC::Connection.new(options)

    commands = XBMC_JSONRPC::JSONRPC.Introspect['result']['commands']
    @commands = {}

    commands.each do |command|
      command_name = command.shift[1]
      @commands[command_name] = command
    end

    return self
  end

  def self.command(method,args)
    @connection.command(method, args)
  end

  def self.commands
    @commands
  end

  def self.apropos(find)
    regexp = /#{find}/im
    matches = []
    @commands.each do |k,v|
      matches.push(k) if k =~ regexp || v['description'] =~ regexp
    end
    if matches.empty?
      puts "\n\nNo commands found, try being less specific\n\n"
    else
      matches.each {|command| self.pp_command command }
    end
  end

  def self.pp_command(command)
    description = @commands[command]['description']
    description = "<no description exists for #{command}>" unless !description.empty?

    puts "\n\t#{command}"
    puts "\t\t#{description}\n\n"
  end

  class Connection

    def initialize(options)
      connection_info = {
        :server => '127.0.0.1',
        :port => 80,
        :user => 'xbmc',
        :pass => 'xbmc'
      }

      @connection_info = connection_info.merge(options)

      @url = URI.parse("http://#{@connection_info[:server]}:#{@connection_info[:port]}/jsonrpc")

    end

    def command(method, params)
      req = Net::HTTP::Post.new(@url.path)
      req.basic_auth @connection_info[:user], @connection_info[:pass]
      req.add_field 'Content-Type', 'application/json'
      req.body = {
        "id" => 1,
        "jsonrpc" => "2.0",
        "method" => method,
        "params" => params
      }.to_json

      res = Net::HTTP.new(@url.host, @url.port).start {|http| http.request(req) }

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        return JSON.parse(res.body)
      else
        res.error!
      end
    rescue StandardError
      puts "Unable to connect to server specified\n"
      exit
    end

  end

  class APIBase

    def self.method_missing(method, args = {})
      apiClass =  self.name.to_s.split('::')[1]
      if method == :get_commands
        XBMC_JSONRPC.commands.keys.sort.grep(/#{apiClass}/) {|command| XBMC_JSONRPC.pp_command(command) }
      else
        XBMC_JSONRPC.command("#{apiClass}.#{method}", args)
      end
    end

#     def self.get_commands
#       p self.name
# #      @commands.keys.grep()
#     end

  end

  class JSONRPC < APIBase

    # def self.Introspect
    # end

    # def self.Version
    # end

    # def self.Permission
    # end

    # def self.Ping
    # end

    # def self.Announce
    # end

  end

  class Player < APIBase

    # def self.GetActivePlayers
    # end

  end

  class AudioPlayer < APIBase
  end

  class VideoPlayer < APIBase

    # def self.PlayPause
    # end

    # def self.Stop
    # end

    # def self.SkipPrevious
    # end

    # def self.SkipNext
    # end

    # def self.BigSkipBackward
    # end

    # def self.BigSkipForward
    # end

    # def self.SmallSkipBackward
    # end

    # def self.SmallSkipForward
    # end

    # def self.Rewind
    # end

    # def self.Forward
    # end

    # def self.GetTime
    # end

    # def self.GetTimeMS
    # end

    # def self.GetPercentage
    # end

    # def self.SeekTime
    # end

    # def self.SeekPercentage
    # end

  end

  class PicturePlayer < APIBase

    # def self.PlayPause
    # end

    # def self.Stop
    # end

    # def self.SkipPrevious
    # end

    # def self.SkipNext
    # end

    # def self.MoveLeft
    # end

    # def self.MoveRight
    # end

    # def self.MoveDown
    # end

    # def self.MoveUp
    # end

    # def self.ZoomOut
    # end

    # def self.ZoomIn
    # end

    # def self.Zoom
    # end

    # def self.Rotate
    # end

  end

  class VideoPlaylist < APIBase

    # def self.Play
    # end

    # def self.SkipPrevious
    # end

    # def self.SkipNext
    # end

    # def self.GetItems
    # end

    # def self.Add
    # end

    # def self.Clear
    # end

    # def self.Shuffle
    # end

    # def self.UnShuffle
    # end

  end

  class AudioPlaylist < APIBase

    # def self.Play
    # end

    # def self.SkipPrevious
    # end

    # def self.SkipNext
    # end

    # def self.GetItems
    # end

    # def self.Add
    # end

    # def self.Clear
    # end

    # def self.Shuffle
    # end

    # def self.UnShuffle
    # end

  end

  class Playlist < APIBase

    # def self.Create
    # end

    # def self.Destroy
    # end

    # def self.GetItems
    # end

    # def self.Add
    # end

    # def self.Remove
    # end

    # def self.Swap
    # end

    # def self.Shuffle
    # end

  end

  class Files < APIBase

    # def self.GetSources
    # end

    # def self.Download
    # end

    # def self.GetDirectory
    # end

  end

  class AudioLibrary < APIBase

    # def self.GetArtists
    # end

    # def self.GetAlbums
    # end

    # def self.GetSongs
    # end

    # def self.ScanForContent
    # end

  end

  class VideoLibrary < APIBase

    # def self.GetMovies
    # end

    # def self.GetTVShows
    # end

    # def self.GetSeasons
    # end

    # def self.GetEpisodes
    # end

    # def self.GetMusicVideoAlbums
    # end

    # def self.GetMusicVideos
    # end

    # def self.GetRecentlyAddedMovies
    # end

    # def self.GetRecentlyAddedEpisodes
    # end

    # def self.GetRecentlyAddedMusicVideos
    # end

    # def self.ScanForContent
    # end

  end

  class System < APIBase

    # def self.Shutdown
    # end

    # def self.Suspend
    # end

    # def self.Hibernate
    # end

    # def self.Reboot
    # end

    # def self.GetInfoLabels
    # end

    # def self.GetInfoBooleans
    # end

  end

  class XBMC < APIBase

    # def self.GetVolume
    # end

    # def self.SetVolume
    # end

    # def self.ToggleMute
    # end

    # def self.Play
    # end

    # def self.StartSlideShow
    # end

    # def self.Log
    # end

    # def self.Quit
    # end

  end

end
