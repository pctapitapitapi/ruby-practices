# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  opt = OptionParser.new
  params = {}
  opt.on('-a') { |v| params[:a] = v }
  opt.on('-r') { |v| params[:r] = v }
  opt.on('-l') { |v| params[:l] = v }
  opt.parse!(ARGV)

  all_files = params[:a] ? Dir.glob('*', File::FNM_DOTMATCH).sort : Dir.glob('*').sort

  if params.empty?
    show_list(all_files)
    return
  end

  all_files = reverse_all_files(all_files) if params[:r]

  if params[:l]
    show_detailed_list(all_files)
  else
    show_list(all_files)
  end
end

def reverse_all_files(all_files)
  all_files.reverse
end

def show_list(all_files)
  row_size = built_row_size(all_files)
  sliced_files = all_files.each_slice(row_size).to_a
  (row_size - sliced_files.last.length).times { sliced_files.last.push('') } if sliced_files.last.length < row_size

  max_length_array = built_max_length_array(sliced_files)
  max_length = max_length_array.max

  sliced_files.transpose.each do |files_element|
    file_names = []
    files_element.each do |file_element|
      lack_of_space = max_length - file_element.length
      file_name = file_element.ljust(lack_of_space + file_element.length, ' ')
      file_names << file_name
    end
    print file_names.join(' ')
    puts
  end
end

def built_row_size(all_files)
  if (all_files.length % 3).zero?
    all_files.length / 3
  else
    all_files.length / 3 + 1
  end
end

def built_max_length_array(sliced_files)
  max_length_array = []
  sliced_files.each do |files_element|
    files_element.each do |file_element|
      max_length_array << file_element.length
    end
  end
  max_length_array
end

def show_detailed_list(all_files)
  total = built_total(all_files)
  puts "total #{total}"
  detailed_list = {}
  all_files.each do |file|
    detailed_list[:file_type] = add_file_type(file)
    detailed_list[:permission] = add_permission(file)
    detailed_list[:hard_link] = add_hard_link(file)
    detailed_list[:user_detail] = add_user_detail(file)
    detailed_list[:byte_size] = add_byte_size(file)
    detailed_list[:file_time] = add_file_time(file)
    detailed_list[:file_name] = File.basename(file)
    detailed_list.each do |_key, value|
      print value
    end
    puts
  end
end

def built_total(all_files)
  total = 0
  all_files.each do |file|
    file = File::Stat.new(file)
    total += file.blocks
  end
  total
end

def add_file_type(file)
  case File.ftype(file)
  when 'file'
    '-'
  when 'directory'
    'd'
  end
end

def add_permission(file)
  file = File::Stat.new(file)
  permission_number = format('%o', file.mode)
  permission_numbers = permission_number.chars.map(&:to_i)
  permission_selections = {
    0 => '---',
    1 => '--x',
    2 => '-w-',
    3 => '-wx',
    4 => 'r--',
    5 => 'r-x',
    6 => 'rw-',
    7 => 'rwx'
  }
  user_permission = permission_numbers[-3]
  group_permission = permission_numbers[-2]
  other_permission = permission_numbers[-1]
  permissions = permission_selections.values_at(user_permission, group_permission, other_permission)
  permissions.join
end

def add_hard_link(file)
  file = File::Stat.new(file)
  hard_link_number = file.nlink
  hard_link_number.to_s.rjust(6)
end

def add_user_detail(file)
  file = File::Stat.new(file)
  user_id = file.uid
  user_name = Etc.getpwuid(user_id).name
  group_id = file.gid
  group_name = Etc.getgrgid(group_id).name
  " #{user_name}  #{group_name}"
end

def add_byte_size(file)
  file = File::Stat.new(file)
  "  #{file.size.to_s.rjust(6)}"
end

def add_file_time(file)
  file = File::Stat.new(file)
  " #{file.mtime.strftime('%_m %d %H:%M')} "
end

main
