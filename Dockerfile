FROM jsalort/texlive2019:latest
MAINTAINER Julien Salort, julien.salort@ens-lyon.fr

# Install libGL
USER root
RUN apt install -y libgl1-mesa-dev

# Install Anaconda in liveuser home
USER liveuser

SHELL ["/bin/bash", "-c"]

RUN wget -q https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh && \
    sh Anaconda3-2020.02-Linux-x86_64.sh -b && \
    rm /home/liveuser/.bashrc && \
    /home/liveuser/anaconda3/bin/conda init bash

# Create py38 conda environment
USER root
COPY py38.yml /home/liveuser/
RUN chown liveuser:liveuser py38.yml

USER liveuser
RUN source /home/liveuser/anaconda3/etc/profile.d/conda.sh && \
    conda env create -f py38.yml -q && \
    conda activate py38 && \
    python -m ipykernel install --user && \
    jupyter lab build

RUN rm -f Anaconda3-2020.02-Linux-x86_64.sh py38.yml

# Set up default shell environment
RUN echo "conda activate py38" >> /home/liveuser/.bashrc
ENV BASH_ENV "/home/liveuser/.bashrc"

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]
