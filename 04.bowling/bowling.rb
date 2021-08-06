# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  case s
  when 'X'
    shots << 10
    shots << 0
  when 'S'
    shots << 10
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << (s == [10, 0] ? [s.shift] : s)
end

point = 0
# 1~9投目までの合計
frames[0..8].each_with_index do |frame, i|
  point += if frame[0] == 10 # ストライクの時
             # ストライクが続いた時
             (frames[i + 1][0] != 10 ? 10 + frames[i + 1][0] + frames[i + 1][1] : 20 + frames[i + 2][0])
           elsif frame.sum == 10 # スペアの時
             10 + frames[i + 1][0] # 次の1投を加算
           else
             frame.sum
           end
end

# 10投目以降を一つの要素にする
frames[9].concat(frames[10]) if frames[10]
frames[9].concat(frames[11]) if frames[11]
frames.slice!(10, 11)

# 10投目の計算
point += if frames[9].sum == 30 # ストライクの時
           30
         elsif frames[9][0] + frames[9][1] == 10 # スペアの時
           10 + frames[9][2]
         else
           frames[9][0] + frames[9][1]
         end

puts point
