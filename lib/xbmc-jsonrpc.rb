# This program allows easy interaction with XBMC's json-rpc API.
# Connection information is provided, and connection is created
# and stored for repeated use.  The list of classes and methods
# available are retrieved from the XBMC json-rpc API, and can be
# accessed or referenced using instance.commands or
# instance.print_commands.  An command can be searched for using
# instance.apropos
#
# Author:: atom smith (http://twitter.com/re5et)
# Copyright:: Copyright (c) 2010 atom smith
# License:: Distributes under the same terms as Ruby

require 'rubygems'
require 'net/http'
require 'json'

# The XBMC_JSONRPC module is a namespace / wrapper

module XBMC_JSONRPC

  # Attempt to create connection with xbmc server, and retrieve available
  # commands.  Accepts connection information arguments and if successful
  # returns a new connection
  def self.new(options = {})
    @connection = XBMC_JSONRPC::Connection.new(options)
    if @connection.command('JSONRPC.Ping')
      @commands = {}
      if @connection.command('JSONRPC.Version')['result']['version']['major'].to_i >= 5
        @commands = @connection.command('JSONRPC.Introspect')['result']['methods']
      else
        commands = @connection.command('JSONRPC.Introspect')['result']['commands']

        commands.each do |command|
          command_name = command.shift[1]
          @commands[command_name] = command
        end
      end
      return self
    end
    return false
  end

  # Make an API call to the instance XBMC server
  def self.command(method,args = {})
    @connection.command(method, args)
  end

  # returns all available commands returned by JSON.Introspect
  def self.commands
    @commands
  end

  # nicely print out all available commands.
  # useful at command line / irb / etc
  def self.get_commands
    @commands.each {|k,v| self.pp_command k  }
    return nil
  end

  # finds and prettily prints appropriate commands based on provided keyword
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
    return nil
  end

  # prettily print out requested command
  def self.pp_command(command)
    description = @commands[command]['description']
    description = "<no description exists for #{command}>" unless !description.empty?

    puts "\n\t#{command}"
    puts "\t\t#{description}\n\n"
  end

  # Class to create and store connection information for xbmc server
  # also handles actual json back and forth.
  class Connection

    def initialize(options)

      connection_info = {
        :server => '127.0.0.1',
        :port => '8080',
        :user => 'xbmc',
        :pass => ''
      }

      @connection_info = connection_info.merge(options)

      @url = URI.parse("http://#{@connection_info[:server]}:#{@connection_info[:port]}/jsonrpc")
    end

    def command(method, params = {})
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

      if res.kind_of? Net::HTTPSuccess
        return JSON.parse(res.body)
      else
        return res.error!
      end
    rescue StandardError
      print "Unable to connect to server specified\n", $!
      return false
    end

  end

  # utility class for others to inherit from.  For now uses method missing
  # to make all calls to the send_command because there is no meaningful
  # difference between namespaces / methods at the moment.
  class APIBase

    # get the correct api namespace to use
    def self.namespace
      @namespace = @namespace || self.name.to_s.split('::')[1]
    end

    # pass on namespace + method and arguments
    def self.method_missing(method, args = {})
      XBMC_JSONRPC.command("#{self.namespace}.#{method}", args)
    end

    # show commands for namespace
    def self.commands
      XBMC_JSONRPC.commands.keys.grep(/#{self.namespace}\./) {|command| XBMC_JSONRPC.pp_command(command) }
    end

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

    # same methods as VideoPlayer

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
