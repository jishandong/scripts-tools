#!/bin/bash

file=$1
title=`basename $file`
echo "draw "$1

echo "
set terminal pngcairo lw 1
set output '$file.png'
set title \"$title\"
set xlabel 'run sequence'
set ylabel 'time used (ms)'
set size ratio 0.5
plot \"$file\" using 1 w lp pt 7 title \"$title\"
set output 
" | gnuplot
