#!/usr/bin/env ruby
require '../lib/air_speakers'

def play_song_number(number)
  @as.play_mp3(@songs[number % @songs.size])
end

def show_help
  puts
  puts "Commands: "
  puts " p = play, n = next, s = stop, q = quit"
end

def get_speaker_host
  if ARGV.size == 1
    ARGV.first
  else
    puts "Searching for speakers..."
    speakers = AirSpeakers.find(0.5)
 
    if speakers.empty?
      puts "No speakers found."
      exit
    elsif speakers.size > 1
      speakers.each_with_index do |speaker, index|
        puts "  #{index + 1}. #{speaker.target}"
      end
      print "Choose a set of speakers: "
      $stdout.flush
      number = gets.to_i
      speakers[number - 1].target
    else
      puts "Using #{speakers.first.target}"
      speakers.first.target
    end
  end
end

def load_songs
  @songs = Dir.glob('*.mp3')
  puts "Loaded #{@songs.size} songs into the playlist."
end
  
host = get_speaker_host

@as = AirSpeakers.new(host)

load_songs
current_song = 0

show_help

play_song_number(current_song)
loop do
  case(STDIN.gets[0].chr)
    when 'p'
      play_song_number(current_song) unless @as.playing?
    when 'n'
      @as.stop
      current_song += 1
      play_song_number(current_song)
    when 's'
      @as.stop
    when 'q'
      break
    when 'h'
      show_help
    else
      show_help
  end
end
