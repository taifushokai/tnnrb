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
「Rubyでニューラルネットを遊ぼう」という題名ですが、PythonではなくRubyなのはPythonではこの分野で解説書も多いのにRubyでは少ないとか、単に私がよくRubyを使っているからという程度です。「ディープラーニング」ではなく「ニューラルネット」なのは人工ニューロン数本レベルのモデルをターゲットとしているからです。その程度だとサンプルがGPUを使わなくてもすぐに終わるというのもありますが、本物のニューロンとの違いも見ていきたいからです。そして「遊ぼう」というのは、そのまま、あまり難し考えないで手を動かしてみようと思っているからです。
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

