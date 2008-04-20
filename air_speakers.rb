#!/usr/bin/ruby

require 'rubygems'
require 'raop'
require 'open3'
require 'dnssd'

Thread.abort_on_exception = true

class AirSpeakers
  attr_accessor :client, :player, :reader, :watcher, :host
  @@speakers = []
  @@resolved_speakers = []
  
  def self.find(delay = 2)
    service = DNSSD.browse('_airport._tcp') do |reply| 
      @@speakers << reply
    end
    sleep delay
    @@speakers.each do |speakers|
      DNSSD.resolve(speakers.name, speakers.type, speakers.domain) do |reply|
        @@resolved_speakers << reply
      end
    end
    sleep delay
    @@resolved_speakers
  end
  
  def initialize(host)
    self.host = host
  end
  

  def connect
    self.client = Net::RAOP::Client.new(host)
    
    info_flush "Connecting To AirSpeakers at #{host}... "
    begin
      client.connect
      info "connected."
    rescue => err
      info "could not connect: "
      info err.inspect
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
end