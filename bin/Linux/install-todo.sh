#!/bin/bash

repo='https://github.com/ginatrapani/todo.txt-cli.git'
tmp='/tmp/install-todo.sh'
bash_c_d='/etc/bash_completion.d'

mkdir -p "$tmp"
cd "$tmp"
git clone $repo
cp todo.sh /usr/local/bin/todo.sh
chmod +x /usr/local/bin/todo.sh
[ -d "$bash_c_d" ] && sudo cp todo_completion "$bash_c_d/todo"
rm -rf "$tmp"

# vim:ts=2:sw=2:sts=2:et:ft=sh

