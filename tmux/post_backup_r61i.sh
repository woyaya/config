#!/bin/sh
_PATH=`realpath $0`
_DIR=`dirname $_PATH`
sed -i 's/^set-option -g history-limit /#set-option -g history-limit /' ${_DIR}/HOME/.tmux.conf
