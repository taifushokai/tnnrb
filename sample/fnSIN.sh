#!/bin/bash

../ruby/fnSIN.rb -m lcheck -o '-g SINe05000@-10-1 -i -e  5000 -p' | ../ruby/sc.rb
../ruby/fnSIN.rb -m lcheck -o '-g SINe10000@-10-1 -i -e 10000 -p' | ../ruby/sc.rb
../ruby/fnSIN.rb -m lcheck -o '-g SINe15000@-10-1 -i -e 15000 -p' | ../ruby/sc.rb
../ruby/fnSIN.rb -m lcheck -o '-g SINe20000@-10-1 -i -e 20000 -p' | ../ruby/sc.rb

