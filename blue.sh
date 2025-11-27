#!/bin/sh

trap reset exit

stty raw -echo

./bin/blue
