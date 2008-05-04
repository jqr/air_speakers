require 'rubygems'
require 'raop'
require 'open3'
require 'dnssd'

Thread.abort_on_exception = true

class AirSpeakers
  attr_accessor :client, :player, :reader, :watcher, :host
  
  def self.find(delay = 2)
    speakers = []
    service = DNSSD.browse('_airport._tcp') do |browse_reply| 
      browse_reply
      DNSSD.resolve(browse_reply.name, browse_reply.type, browse_reply.domain) do |resolve_reply|
        speakers << resolve_reply
      end
    end
    sleep delay
    speakers
  end
  
  def initialize(host)
    self.host = host
  end
  
  def connect
    self.client = Net::RAOP::Client.new(host)
    
    begin
      client.connect
    rescue => err
      error "Could not connect to #{host}: "
      error err.inspect
    end
  end

  def volume=(level)
    client.volume = level
  end

  def broadcast(data)
    client.play data
  end
  
  def play_mp3(file)
    escaped_file = file.gsub(/ /, '\ ')
    lame_in, lame_out, lame_err = Open3.popen3("lame -t --decode #{escaped_file} -")
    file = File.basename(file)
  
    if player
      false
    else
      connect
      self.volume = 1

      self.player = Thread.new do
        info_flush "Playing #{file}..."
        broadcast(lame_out)
        info "Finished Playing"
      end
      
      true
    end
  end
  
  def playing?
    !!player
  end
    
  def stop
    if player
      info "Stopping"
      player.kill 
      client.disconnect
      self.player = nil
      true
    end
  end
  
  def info_flush(message)
    print message
    $stdout.flush
  end

  def info(message)
    puts message
  end

  def error(message)
    puts error
  end
end