#!/bin/bash

killall ROP_file_creator.sh

docker stop $(docker ps -aq); docker rm $(docker ps -aq)

./mass-pnf-sim.py --clean

