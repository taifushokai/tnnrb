#!/usr/bin/env ruby
#
#= sin曲線の学習

require 'optparse'
require 'yaml'

$span  = Math::PI * 2 * 2
$dsize = 128

def main
  mode    = "learn"
  options = ""

  opts = OptionParser.new
  opts.on("-m MODE", "--mode MODE", "learn,check,lckeck,answer") do |val|
    mode = val
  end
  opts.on("-o SC-OPTIONS", "--options SC-OPTIONS", "ex) '-g X-1 -i -e 10000'") do |val|
    options = val
  end
  opts.on("-s SPAN", "--span SPAN", "x span") do |val|
    $span = val.to_f
  end
  opts.on("-d DSZIE", "--dsize DSIZE", "dividing size") do |val|
    $dsize = val.to_i
  end
  opts.parse(ARGV)

  xA = [] # 入力値
  yA = [] # 関数値
  dx = $span.to_f / $dsize
  x = 0.0
  0.step($dsize) do |ix|
    xA << [x]
    x += dx
  end
  if mode != "answer"
    xA.each do |x, *|
      y = Math::sin(x) # ←学習させる関数
      yA << [y]
    end
  end

  YAML::dump({'mode' => mode, 'options' => options, 'xA' => xA, 'yA' => yA}, STDOUT)
end

main

