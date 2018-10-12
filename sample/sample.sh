#!/bin/bash

for rq in \
  fnSIN.sh \
  fnSINSIN.sh \
  fnXSIN.sh \
  fnCYLINDER.sh \
  ; do cmd="time -p ./$rq"; echo \$ $cmd; $cmd; echo; done


