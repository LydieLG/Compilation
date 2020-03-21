#!/bin/bash

if [ "$#" -ne 1 ]
then
 echo "Le nombre d'arguments est invalide"
fi
if [ "$#" -eq 1 ]
then
  make
  cat $1 | ./myc
  gcc -std=c99 -Wall -o test/test test/test.c && ./test/test
fi
