# frozen_string_literal: true

require 'optparse'

def main
  parsed_input = parse_input(ARGV)

  final_total = { lines: 0, words: 0, letters: 0 }
  if parsed_input[:options][:l]
    parsed_input[:files].each do |file|
      show_only_lines(file[:content])
    end
  else
    parsed_input[:files].each do |file|
      reading_contents_total = built_total(file[:content])
      show_reading_contents_total(reading_contents_total, file[:name])
      add_total(reading_contents_total, final_total)
    end
  end

  return if parsed_input[:files].size == 1

  show_final_total(final_total)
end

def parse_input(argv)
  opt = OptionParser.new
  options = {}
  opt.on('-l') { |v| options[:l] = v }
  opt.parse!(argv)

  files = built_files(argv)
  {
    options: options,
    files: files
  }
end

def built_files(argv)
  if argv.empty?
    [{
      name: '',
      content: $stdin.readlines
    }]
  else
    argv.map do |file_name|
      {
        name: file_name,
        content: File.readlines(file_name)
      }
    end
  end
end

def show_only_lines(reading_contents)
  reading_contents_total = built_total(reading_contents)
  print reading_contents_total[:lines].to_s.rjust(8)
end

def built_total(lines)
  building_total = { lines: 0, words: 0, letters: 0 }
  lines.each do |line|
    building_total[:lines] += count_lines(line)
    building_total[:words] += count_words(line)
    building_total[:letters] += count_letters(line)
  end
  building_total
end

def count_lines(line)
  line.lines.count
end

def count_words(line)
  line.split(/\s+/).count
end

def count_letters(line)
  line.bytesize
end

def show_inputted_lines_total(inputted_lines_total)
  inputted_lines_total.each do |_k, total|
    print total.to_s.rjust(8)
  end
end

def show_reading_contents_total(reading_contents_total, file_name)
  reading_contents_total.each do |_k, total|
    print total.to_s.rjust(8)
  end
  print " #{file_name}"
  puts
end

def add_total(reading_contents_total, final_total)
  final_total[:lines] += reading_contents_total[:lines]
  final_total[:words] += reading_contents_total[:words]
  final_total[:letters] += reading_contents_total[:letters]
end

def show_final_total(final_total)
  final_total.each do |_k, v|
    print v.to_s.rjust(8)
  end
  print ' total'
end

main
