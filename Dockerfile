FROM jsalort/texlive2019:latest

COPY py38.yml /home/liveuser/
SHELL ["/bin/bash", "-c"]

RUN wget -q https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh && \
    sh Anaconda3-2019.10-Linux-x86_64.sh -b && \
    /home/liveuser/anaconda3/bin/conda init bash

RUN source /home/liveuser/anaconda3/etc/profile.d/conda.sh && \
    conda env create -f py38.yml -q && \
    conda activate py38 && \
    python -m ipykernel install --user && \
    jupyter lab build && \
    rm -f /home/liveuser/.bashrc

ENV CONDA_SHLVL "2"
ENV CONDA_PROMPT_MODIFIER "(py38)"
ENV CONDA_EXE "/home/liveuser/anaconda3/bin/conda"
ENV _CE_CONDA ""
ENV CONDA_PREFIX_1 "/home/liveuser/anaconda3"
ENV PATH "/home/liveuser/anaconda3/envs/py38/bin:/home/liveuser/anaconda3/bin:/home/liveuser/anaconda3/condabin:/usr/local/texlive/2019/bin/x86_64-linux:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV CONDA_PREFIX "/home/liveuser/anaconda3/envs/py38"
ENV _CE_M ""
ENV SHLVL "1"
ENV CONDA_PYTHON_EXE "/home/liveuser/anaconda3/bin/python"
ENV CONDA_DEFAULT_ENV "py38"
