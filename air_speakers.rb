#!/usr/bin/ruby

require 'rubygems'
require 'raop'
require 'open3'
require 'dnssd'

Thread.abort_on_exception = true

class AirSpeakers
  attr_accessor :client, :player, :reader, :watcher
  @@speakers = []
  
  def self.find
    service = DNSSD.browse('_airport._tcp') do |reply| 
      @@speakers << reply
    end
  end
  
  def self.lsit
    @@speakers
  end
    
  def initialize(ip)
    @ip = ip
  end
  

  def connect
    self.client = Net::RAOP::Client.new(@ip)
    
    info_flush "Connecting To AirSpeakers at #{@ip}... "
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
    lame_in, lame_out, lame_err = Open3.popen3("lame --decode #{file} -")
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