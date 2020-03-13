#! /bin/bash

docker run -it --rm -p 8888:8888 -v ${PWD}:/home/liveuser/workdir -w /home/liveuser/workdir jsalort/py38:latest jupyter lab --ip=0.0.0.0 --port 8888
