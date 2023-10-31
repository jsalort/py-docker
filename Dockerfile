FROM jsalort/texlive:latest AS base
MAINTAINER Julien Salort, julien.salort@ens-lyon.fr

# Install libGL (used by Jupyter lab)
USER root
RUN echo 2023-10-31
RUN apt update && \
    apt install -y libgl1-mesa-dev

# Dependencies for Chromium (used by the betatim/notebook-as-pdf extension)
RUN apt install -y libxcomposite1 libxcursor1 libxi6 libxtst6 libglib2.0-0 \
                   libnss3 libxss1 libxrandr2 libasound2 libpangocairo-1.0-0 \
                   libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 gfortran \
                   curl mercurial git meson nodejs

# Python 3.10 system packages
RUN apt install -y python3.11 python3.11-doc \
                   python3-arrow python3-babel python3-configargparse \
                   python3-cycler python3-dateutil python3-filelock \
                   python3-flake8 python3-flask python3-flask-babel \
                   python3-importlib-metadata python3-jinja2 python3-markdown \
                   python3-matplotlib python3-numpy python3-openpyxl \
                   python3-pandas python3-pil python3-pip python3-pygeoip \
                   python3-pymysql python3-requests python3-scipy \
                   python3-serial python3-sqlalchemy python3-ua-parser \
                   python3-user-agents python3-venv python3-ipykernel \
                   python3-ipywidgets python3-jupyter-console \
                   python3-jupyter-sphinx python3-nbconvert \
                   python3-nbformat python3-nbsphinx python3-notebook \
                   python3-widgetsnbextension python3-aiohttp \
                   python3-aiohttp-jinja2 python3-sphinx-argparse \
                   python3-sphinx-rtd-theme python3-sphinxcontrib.bibtex \
                   python3-h5py python3-opencv python3-skimage python3-aiodns \
                   python3-numba python3-aioftp pre-commit python3-pint \
                   python3-mesonpy cython3

# Create virtualenv in liveuser home
USER liveuser
SHELL ["/bin/bash", "-c"]

# Set up default shell environment
RUN python3 -m venv --system-site-packages /home/liveuser/ve311
ENV VIRTUAL_ENV /home/liveuser/ve311
RUN echo "source /home/liveuser/ve311/bin/activate" >> /home/liveuser/.bashrc
ENV BASH_ENV "/home/liveuser/.bashrc"
ENV SETUPTOOLS_USE_DISTUTILS "stdlib"
ENV OMP_NUM_THREADS "1"
ENV QT_QPA_PLATFORM "offscreen"
ENV XDG_RUNTIME_DIR "/tmp/runtime-liveuser"

FROM base AS branch-amd64
ENV PATH /home/liveuser/ve311/bin:/usr/local/texlive/2023/bin/x86_64-linux:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

FROM base AS branch-arm64
ENV PATH /home/liveuser/ve311/bin:/usr/local/texlive/2023/bin/aarch64-linux:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

FROM branch-${TARGETARCH} as final

# Install Additionnal modules
RUN python -m pip install --upgrade pip setuptools
RUN python -m pip install jupyterlab
RUN python -m ipykernel install --user
RUN python -m pip install coolprop
RUN python -m pip install progressbar2 pyvisa pyvisa-py numpy_groupies llc nptdms
# RUN python -m pip install pyqt5
RUN python -m pip install --upgrade numpy  # il faut mettre avant numba qui downgrade à la dernière version compatible
RUN python -m pip install --upgrade sphinx
RUN python -m pip install --upgrade aiohttp_jinja2
RUN python -m pip install --upgrade pint
RUN python -m pip install --upgrade sqlalchemy
RUN python -m pip install --upgrade transonic
RUN python -m pip install --upgrade numba

RUN jupyter lab build
# RUN jupyter labextension install jupyter-matplotlib  # deprecated
RUN python -m pip install notebook-as-pdf
RUN pyppeteer-install


# Add FluidDyn, FluidLab and FluidImage from Heptapod
RUN hg clone https://foss.heptapod.net/fluiddyn/fluiddyn && \
    python -m pip install ./fluiddyn && \
    rm -fr /home/liveuser/fluiddyn && \
    hg clone https://foss.heptapod.net/fluiddyn/fluidlab && \
    python -m pip install ./fluidlab && \
    rm -fr /home/liveuser/fluidlab && \
    hg clone https://foss.heptapod.net/fluiddyn/fluidimage && \
    python -m pip install ./fluidimage && \
    rm -fr /home/liveuser/fluidimage

# Add pymanip from Github
RUN git clone https://github.com/jsalort/pymanip.git && \
    python -m pip install ./pymanip && \
    rm -fr /home/liveuser/pymanip

# Add pyciv from Gitlab
RUN git clone https://gitlab.salort.eu/jsalort/pyciv.git && \
    python -m pip install /home/liveuser/pyciv/civx_fc && \
    python -m pip install /home/liveuser/pyciv/pyciv && \
    rm -fr /home/liveuser/pyciv
