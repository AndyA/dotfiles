#!/bin/sh

PATH=/alt/local/bin:$PATH

stamp=$(date '+%Y%m%d-%H%M%S')

repo=git://github.com/AndyA/Test-Harness.git

work=~/.smoke-work
logdir=$work/log
proj=$work/repo
work=$proj/Test-Harness
log=$logdir/$stamp-runlog

mkdir -p $proj $logdir
find $logdir -mtime +1 -print0 | xargs -0 rm

# Grab the latest version
if [ -d $work ]; then
    cd $work
    git pull $repo master > $log 2>&1
else
    cd $proj
    git clone $repo > $log 2>&1
    cd $work
fi

perl smoke/smoke.pl -v smoke/config.surly >> $log 2>&1
