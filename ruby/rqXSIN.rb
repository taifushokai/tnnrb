#!/usr/bin/env ruby
#
#= 平面＋sin曲面の学習

require 'optparse'
require 'yaml'

SIZE = 32

def main
  mode    = "learn"
  options = ""

  opts = OptionParser.new
  opts.on("-m MODE", "--mode MODE", "learn,check,lcheck,answer") do |val|
    mode = val
  end
  opts.on("-o SC-OPTIONS", "--options SC-OPTIONS", "ex) '-g X-1 -i -l 10000'") do |val|
    options = val
  end
  opts.parse(ARGV)

  xA = [] # 入力値
  yA = [] # 関数値
  ux = Math::PI * 2 / SIZE
  x0 = 0.0
  0.step(SIZE) do |ix0|
    x1 = 0.0
    0.step(SIZE) do |ix1|
      xA << [x0, x1]
      x1 += ux
    end
    x0 += ux
  end
  if mode != "answer"
    xA.each do |x0, x1, *|
      if x0 < Math::PI
        y0 = x1 / Math::PI # ←学習させる関数
      else
        y0 = Math::sin(x1) # ←学習させる関数
      end
      yA << [y0]
    end
  end

  YAML::dump({'mode' => mode, 'options' => options, 'xA' => xA, 'yA' => yA}, STDOUT)
end

main

