FROM jsalort/texlive:latest
MAINTAINER Julien Salort, julien.salort@ens-lyon.fr

# Install libGL (used by Jupyter lab)
USER root
RUN apt update && \
    apt install -y libgl1-mesa-dev

# Dependencies for Chromium (used by the betatim/notebook-as-pdf extension)
RUN apt install -y libxcomposite1 libxcursor1 libxi6 libxtst6 libglib2.0-0 \
                   libnss3 libxss1 libxrandr2 libasound2 libpangocairo-1.0-0 \
                   libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0

# Python 3.8 system packages
RUN apt install -y python3.9 python3.9-doc \
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
                   python3-numba

# Nodejs >= 12 is a dependency for jupyterlab build
RUN apt install -y curl mercurial git
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt install -y nodejs

# Create virtualenv in liveuser home
USER liveuser
SHELL ["/bin/bash", "-c"]

RUN python3 -m venv --system-site-packages /home/liveuser/ve39
RUN source /home/liveuser/ve39/bin/activate && \
    python -m pip install jupyterlab && \
    python -m ipykernel install --user && \
    jupyter lab build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyter-matplotlib && \
    python -m pip install notebook-as-pdf && \
    pyppeteer-install

# Set up default shell environment
ENV VIRTUAL_ENV /home/liveuser/ve39
ENV PATH /home/liveuser/ve39/bin:/usr/local/texlive/2021/bin/x86_64-linux:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN echo "source /home/liveuser/ve39/bin/activate" >> /home/liveuser/.bashrc
ENV BASH_ENV "/home/liveuser/.bashrc"

# Add fluiddyn and fluidlab from heptapod
RUN hg clone https://foss.heptapod.net/fluiddyn/fluiddyn && \
    cd /home/liveuser/fluiddyn && python setup.py install && \
    cd /home/liveuser && rm -fr /home/liveuser/fluiddyn && \
    hg clone https://foss.heptapod.net/fluiddyn/fluidlab && \
    cd /home/liveuser/fluidlab && python setup.py install && \
    cd /home/liveuser && rm -fr /home/liveuser/fluidlab

# Additionnal modules
RUN python -m pip install progressbar2 pyvisa pyvisa-py aioftp pre-commit pint numpy_groupies llc nptdms
