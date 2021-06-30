require 'date'
require 'optparse'

opt = OptionParser.new

# コマンドオプションの解析と取得
opt.on('-m')
opt.on('-y')
opt.parse!(ARGV)
month = ARGV[0].to_i
year = ARGV[1].to_i

# オプションがゼロの時とnilの確認
case
when month == 0 && year == 0 || month.nil? && year.nil?
  month = Date.today.month
  year = Date.today.year
when year == 0
  year = Date.today.year
end

puts "#{month}月 #{year}".center(18)

date_begin = Date.new(year, month, 1)
date_end = Date.new(year, month, -1)
today_day = Date.today

# 曜日の取得
days_week = ["日", "月", "火", "水", "木", "金", "土"]
puts days_week.join(" ")

# 日付の取得
(date_begin.wday * 3).times { print " " }
(date_begin..date_end).each do |date|
  case
  when date == today_day && date.day < 10
      print " " + "\e[30m\e[47m#{today_day.day}\e[0m" + " "
  when date == today_day && date.day >= 10
      print "\e[30m\e[47m#{today_day.day}\e[0m" + " "
  else
    print "#{date.day.to_s.rjust(2)}"+ " "
  end
  if date.saturday? || date == date_end
    print "\n"
  end
end
