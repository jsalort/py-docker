# py38-docker

This is my personal Anaconda Python 3.8 docker file for use with Gitlab Runner. It is based
on [texlive2019 docker file](https://github.com/jsalort/texlive2019-docker), so it has
both Python and Texlive (useful to compile documentation, or plot with LaTeX).

This dockerfile is published on [Docker Hub](https://hub.docker.com/repository/docker/jsalort/py38).

To use it locally:
```bash
$ docker pull jsalort/py38:latest
$ docker run -it jsalort/py38:latest python
```

Or, to run a Jupyter Lab instance:
```bash
$ docker run -it -p 8888:8888 -v ${PWD}:/home/liveuser/workdir -w /home/liveuser/workdir jsalort/py38:2019.10 jupyter lab --ip=0.0.0.0 --port 8888
```
or alternatively, use the provided `run_jupyter.sh` script, i.e.
```bash
$ sh run_jupyter.sh
```
