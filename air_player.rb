require 'air_speakers'

def play_song_number(number)
  @as.play_mp3(@songs[number % @songs.size])
end

def show_help
  puts
  puts "Commands: "
  puts " p = play, n = next, s = stop, q = quit"
end



@songs = Dir.glob('*.mp3')
current_song = 0

puts "#{@songs.size} songs loaded:"
@songs.each do |song|
  puts "  #{song}"
end

puts "Searching for speakers..."
speakers = AirSpeakers.find(0.5)
host = 
  if speakers.size > 1
    puts "Available speakers:"
    speakers.each_with_index do |speaker, index|
      puts "  #{index + 1}. #{speaker.target}"
    end
    puts "Enter Speaker Number:"
    number = gets.to_i
    speakers[number - 1].target
  else
    puts "Using #{speakers.first.target}"
    speakers.first.target
  end

@as = AirSpeakers.new(host)
show_help

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