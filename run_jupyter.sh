#! /bin/bash

docker run -it --rm --name jupyterlab -p 8888:8888 -v ${PWD}:/home/liveuser/workdir -w /home/liveuser/workdir jsalort/py:3.8 jupyter lab --ip=0.0.0.0 --port 8888
