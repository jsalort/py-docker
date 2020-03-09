#! /bin/bash

docker run -it -p 8888:8888 -v ${PWD}:/home/liveuser/workdir -w /home/liveuser/workdir jsalort/py38:2019.10 jupyter lab --ip=0.0.0.0 --port 8888
