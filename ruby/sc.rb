#!/usr/bin/env ruby
#
#= Simple Chain YAML input

require 'optparse'
require 'yaml'
require 'numo/narray'
require 'chainer'

L = Chainer::Links::Connection::Linear
F = Chainer::Functions

class SimpleChain < Chainer::Chain
  def initialize(geometry)
    @nuA = []
    if /\w*?X-([\d\-]+)/ =~ geometry
      geometry = $&
      $1.split("-").each do |nu|
        if nu.to_i < 1
          @nuA << 1
        else
          @nuA << nu.to_i
        end
      end
    else
      raise "BAD GEOMETRY"
    end

    super()
    init_scope do
      @l1 = L.new(nil, out_size: @nuA[0]) if @nuA.size >= 1
      @l2 = L.new(nil, out_size: @nuA[1]) if @nuA.size >= 2
      @l3 = L.new(nil, out_size: @nuA[2]) if @nuA.size >= 3
      @l4 = L.new(nil, out_size: @nuA[3]) if @nuA.size >= 4
      @l5 = L.new(nil, out_size: @nuA[4]) if @nuA.size >= 5
    end
    @optimizer = Chainer::Optimizers::Adam.new
    @optimizer.setup(self)

    @desc = {'geometry' => geometry}
    @desc['desc_path']  = @desc['geometry'] + ".yaml"
    @desc['net_path']   = @desc['geometry'] + ".net"
    @desc['last_score'] = 0.0
    @desc['learn_time'] = 0.0
    @desc['learn_count'] = 0
    @learn_start = nil
    @learn_count = 0
  end

  #=== 順方向伝搬
  def forward(xV)
    fV = nil
    if @nuA.size >= 1
      fV = @l1.(xV)
      if @nuA.size >= 2
        fV = @l2.(F::Activation::Sigmoid.sigmoid(fV))
        if @nuA.size >= 3
          fV = @l3.(F::Activation::Sigmoid.sigmoid(fV))
          if @nuA.size >= 4
            fV = @l4.(F::Activation::Sigmoid.sigmoid(fV))
            if @nuA.size >= 5
              fV = @l5.(F::Activation::Sigmoid.sigmoid(fV))
            end
          end
        end
      end
    end
    return fV
  end

  #=== 学習
  def learn(xV, yV)
    @learn_start = Time::now unless @learn_start
    @learn_count += 1
    self.cleargrads()
    F::Loss::MeanSquaredError.mean_squared_error(forward(xV), yV).backward()
    @optimizer.update()
  end

  #== 成績の記録
  def last_score=(score)
    @desc['last_score'] = score
  end

  #== ジオメトリ文字列
  def geometry()
    return @desc['geometry']
  end

  #== 各記録、ネットのファイル保存
  # @learn_start の値がある場合、学習があったとして更新する。
  def save()
    if @learn_start
      @desc['learn_time'] += (Time::now - @learn_start)
      @desc['learn_count'] += @learn_count
      Chainer::Serializers::MarshalSerializer.save_file(@desc['net_path'], self)
    end
    YAML.dump(@desc, open(@desc['desc_path'], "w"))
  end

  #== 各記録、ネットのファイルからの読み込み
  def load()
    if FileTest::exist?(@desc['desc_path'])
      @desc = YAML.load_file(@desc['desc_path'])
    end
    if FileTest::exist?(@desc['net_path'])
      Chainer::Serializers::MarshalDeserializer.load_file(@desc['net_path'], self)
    end
    @load_time = Time::now.to_f
  end
end

def main
  mode     = "learn"
  geometry = "X-1"
  loopsize = 1000
  initflag = false
  dumpflag = false
  plotflag = false

  req = YAML::load_stream(STDIN)[0]
  mode = req["mode"] if req["mode"]
  optionsA = req["options"].to_s.split(/\s+/)

  opts = OptionParser.new
  opts.on("-m MODE", "--mode MODE", "learn,check,lcheck,answer") do |val|
    mode = val
  end
  opts.on("-g abcX-9-9-9-9-9", "--geometry abcX-9-9-9-9-9", "NN geometry , default X-1") do |val|
    geometry = val
  end
  opts.on("-l LOOP", "--loop LOOP", "learning loop size") do |val|
    loopsize = val.to_i
  end
  opts.on("-i [false]", "--init [false]", "initialize net file") do |val|
    if val == "false"
      initflag = false
    else
      initflag = true
    end
  end
  opts.on("-d [false]", "--dump [false]", "dump") do |val|
    if val == "false"
      dumpflag = false
    else
      dumpflag = true
    end
  end
  opts.on("-p [false]", "--plot [false]", "plot") do |val|
    if val == "false"
      plotflag = false
    else
      plotflag = true
    end
  end
  optionsA.concat(ARGV)
  opts.parse(optionsA)

  model = SimpleChain.new(geometry)
  model.load() unless initflag
  case mode
  when 'learn'
    learn(model, req['xA'], req['yA'], dumpflag, loopsize)
    model.save()
  when 'check'
    score = check(model, req['xA'], req['yA'], dumpflag, plotflag)
    model.last_score = score
    model.save()
  when 'lcheck'
    learn(model, req['xA'], req['yA'], dumpflag, loopsize)
    score = check(model, req['xA'], req['yA'], dumpflag, plotflag)
    model.last_score = score
    model.save()
  when 'answer'
    answer(model, req['xA'])
  end
end

#=== 学習
def learn(model, xA, yA, dumpflag, loopsize)
  xN = Numo::SFloat.cast(xA)
  xV = Chainer::Variable.new(xN)
  yN = Numo::SFloat.cast(yA)
  yV = Chainer::Variable.new(yN)
  STDERR.print("LEARNING") if dumpflag
  loopsize.times do |ix|
    STDERR.print(".") if dumpflag and (ix % 100 == 0)
    model.learn(xV, yV)
  end
  STDERR.print("\n") if dumpflag
end

#=== 学習のチェック
def check(model, xA, yA, dumpflag, plotflag)
  xN = Numo::SFloat.cast(xA)
  xV = Chainer::Variable.new(xN)
  fV = model.forward(xV)
  ok = 0
  yA.each_with_index do |y, ix|
    f = fV.data[ix, 0]
    if y[0] == 0.0
      if f == 0.0
        ok += 1
        eql = "=="
      else
        eql = "<>"
      end
    else
      if ((f - y[0]) / y[0]).abs < 0.1
        ok += 1
        eql = "=="
      else
        eql = "<>"
      end
    end
    STDERR.printf("%d)\t%6.2f %s %6.2f\n", ix, f, eql, y[0]) if dumpflag
  end
  score = ok.to_f / yA.size
  printf("CHECK RESULT: %d/%d = %.1f%%\n\n", ok, yA.size, score * 100)

  if plotflag
    datpath = "#{model.geometry()}.dat"
    pngpath = "#{model.geometry()}.png"
    if xA[0].to_a.size <= 1
      open(datpath, "w") do |wh|
        xA.each_with_index do |x, ix|
          x0 = x[0]
          y0 = yA[ix][0]
          f = fV.data[ix, 0]
          wh.printf("%f %f %f\n", x0, y0, f)
        end
      end
      IO::popen("gnuplot > /dev/null 2>&1", "w") do |ph|
        ph.print(<<EOT)
set terminal png
set output '#{pngpath}'
plot "#{datpath}" using 1:2 w lp title "y", "#{datpath}" using 1:3 w lp title "f(x)"
EOT
      end
    else
      open(datpath, "w") do |wh|
        xA.each_with_index do |x, ix|
          x0 = x[0]
          x1 = x[1]
          y0 = yA[ix][0]
          f = fV.data[ix, 0]
          wh.printf("%f %f %f %f\n", x0, x1, y0, f)
        end
      end
      IO::popen("gnuplot > /dev/null 2>&1", "w") do |ph|
        ph.print(<<EOT)
set terminal png
set output '#{pngpath}'
#splot "#{datpath}" using 1:2:3 w lp title "y", "#{datpath}" using 1:2:4 w lp title "f(x)"
splot "#{datpath}" using 1:2:3 w p title "y", "#{datpath}" using 1:2:4 w p title "f(x)"
EOT
      end
    end
    system("eog #{pngpath} 2> /dev/null &")
  end

  return score
end

#=== ネットによる回答
def answer(model, xA)
  xN = Numo::SFloat.cast(xA)
  xV = Chainer::Variable.new(xN)
  fV = model.forward(xV)
  xA.each_with_index do |x, ix|
    f = fV.data[ix, 0]
    printf("%d)\t%s\t-> %6.2f\n", ix, x.to_s, f)
  end
end

main

