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

  all_files = Dir.glob('*').sort
  if params.empty?
    build_list(all_files)
    return
  end
  all_files_a = option_a(all_files, params)
  all_files_r = option_r(all_files_a, params)
  all_files_l = option_l(all_files_r, params)
  build_list(all_files_l) unless params[:l]
end

def option_a(all_files, params)
  if params[:a]
    Dir.glob('*', File::FNM_DOTMATCH).sort
  else
    all_files
  end
end

def option_r(all_files_a, params)
  if params[:r]
    all_files_a.reverse
  else
    all_files_a
  end
end

def option_l(all_files_r, params)
  if params[:l]
    built_option_l(all_files_r)
  else
    all_files_r
  end
end

def built_option_l(all_files)
  total = 0
  all_files.each do |file|
    file = File::Stat.new(file)
    total += file.blocks
  end
  puts "total #{total}"
  add_file_type(all_files)
end

def build_list(all_files)
  row_size = if (all_files.length % 3).zero?
               all_files.length / 3
             else
               all_files.length / 3 + 1
             end
  sliced_files = all_files.each_slice(row_size).to_a
  (row_size - sliced_files.last.length).times { sliced_files.last.push('') } if sliced_files.last.length < row_size

  max_length_array = []
  sliced_files.each do |files_element|
    files_element.each do |file_element|
      max_length_array << file_element.length
    end
  end
  max_length = max_length_array.max
  show_list(sliced_files, max_length)
end

def show_list(sliced_files, max_length)
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

def add_file_type(all_files)
  all_files.each do |file|
    case File.ftype(file)
    when 'file'
      print '-'
    when 'directory'
      print 'd'
    end
    add_permission(file)
    add_hard_link(file)
    add_user_detail(file)
    add_byte_size(file)
    add_file_time(file)
    add_file_name(file)
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
  print permissions.join
end

def add_hard_link(file)
  file = File::Stat.new(file)
  hard_link_number = file.nlink
  print hard_link_number.to_s.rjust(6)
end

def add_user_detail(file)
  file = File::Stat.new(file)
  user_id = file.uid
  user_name = Etc.getpwuid(user_id).name
  group_id = file.gid
  group_name = Etc.getgrgid(group_id).name
  print " #{user_name}"
  print "  #{group_name}"
end

def add_byte_size(file)
  file = File::Stat.new(file)
  print "  #{file.size.to_s.rjust(6)}"
end

def add_file_time(file)
  file = File::Stat.new(file)
  print " #{file.mtime.strftime('%_m %d %H:%M')} "
end

def add_file_name(file)
  puts File.basename(file)
end

main
