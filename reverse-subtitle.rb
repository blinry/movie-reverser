require "srt"

if ARGV.size != 2
  raise "Please supply a video and a subtitle file as arguments."
end

video_filename = ARGV[0]
subtitle_filename = ARGV[1]

unless subtitle_filename =~ /\.srt$/
  raise "Second argument must be a srt file"
end

def get_movie_duration video_file
  # Run ffmpeg on the video, and do it silently
  ffmpeg_output = `ffmpeg -i "#{video_file}" 2>&1`

  # Find the duration in the output, and force a return if it's found
  /duration: ([0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{2})/i.match(ffmpeg_output) { |m| return SRT::Parser.timecode(m[1]) }

  # If it didn't get a match, something is wrong. Log the error
  raise "could not get duration from videofile"
end

movie_length = get_movie_duration(video_filename)
file = SRT::File.parse(File.new(subtitle_filename))

file.lines = file.lines.reverse

file.lines.each_with_index do |line, i|
  line.start_time, line.end_time = movie_length - line.end_time, movie_length - line.start_time
  line.sequence = i + 1
  puts line.time_str
  puts line.text.join(" ")
end

puts file.to_s
