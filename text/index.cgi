#!/usr/bin/env ruby

def main
  title = "Rubyでニューラルネットを遊ぼう！"
  tags = [
    "enveronment",
    "simple_model",
    "artificial_neuron",
    "experiment_direction"
  ]

  index = ""
  body = ""
  tags.each_with_index do |tag, no|
    (subj, text) = readtext(tag)
    text.gsub!("\n", "<br />\n")
    index << <<EOT
<a href="##{tag}">#{no + 1} #{subj}</a><br />
EOT
    body << <<EOT
<h2 id="#{tag}">#{no + 1} #{subj}</h2>
<p>
#{text}
</p>
EOT
  end
  print <<EOT
Content-type: text/html

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>#{title}</title>
</head>
<body>
<h1>*** #{title} ***</h1>
<p>
近年、ディープラーニングの研究と応用は凄まじく、応用面では人間の能力を超える事例も出てきています。ただ、ディープラーニングやニューラルネットの研究の進歩が人間の心の原理をも明らかにしているかという見方をすると、だいぶ方向性に違いができてきたのかなと思います。ディープラーニングやニューラルネット研究の奔流がより広範囲の認識能力やビックデータとの融合、さらには究極のオートメーションに向かっているのに対して、人間の心の理解は少しづつは進んでいるように見えるものの、精神科では試行錯誤による投薬程度しかできていないのが現状ではないでしょうか。（もちろん、精神科でも検査キットを使って数分で特効薬が提供できるみたいな状況を望んでいるわけではないですが。）
</p>
<p>
本書ではまず、ディープラーニングに使われる人工ニューロンの動作を確認し、「心」サイドから見た場合それがどのような位置にあるものなのかを考えたいと思います。
例題として使わせていただくディープラーニングのフレームワークとしては github で公開されいる red-chainer(https://github.com/red-data-tools/red-chainer) にしてみました。これは Python で実装されたメジャーなフレームワークである Chainer(https://chainer.org/) の Ruby によるポーティングです。
</p>
<p>
Rubyでニューラルネットを遊ぼう」という題名ですが、PythonではなくRubyなのはPythonではこの分野で解説書も多いのにRubyでは少ないとか、単に私がよくRubyを使っているからという程度です。「ディープラーニング」ではなく「ニューラルネット」なのは人工ニューロン数本レベルのモデルをターゲットとしているからです。その程度大きさだとサンプルがGPUを使わなくても計算がすぐに終わるというのもありますが、本物のニューロンとの違いも見ていきたいからです。そして「遊ぼう」というのは、そのまま、あまり難しく考えないで手を動かしてみようと思っているからです。
</p>
EOT
  print index
  print body
  print <<EOT
</body>
</html>
EOT
end

def readtext(tag)
  subj = nil
  text = nil
  buff = nil
  open("#{tag}.txt") do |fh|
    buff = fh.read.strip
  end
  (subj, text) = buff.split("\n\n", 2)
  return subj, text
end 

main

