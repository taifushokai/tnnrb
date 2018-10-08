#!/bin/bash

for rq in \
  rqSIN.sh \
  rqSINSIN.sh \
  rqXSIN.sh \
  rqCYLINDER.sh \
  ; do cmd="time -p ./$rq"; echo \$ $cmd; $cmd; echo; done


