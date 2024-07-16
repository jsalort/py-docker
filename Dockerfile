FROM jsalort/texlive:latest AS base
LABEL org.opencontainers.image.authors="julien.salort@ens-lyon.fr"

# Install libGL (used by Jupyter lab)
USER root
RUN echo 2024-07-15
RUN apt update && \
    apt install -y libgl1-mesa-dev

# Dependencies for Chromium (used by the betatim/notebook-as-pdf extension)
RUN apt install -y libxcomposite1 libxcursor1 libxi6 libxtst6 libglib2.0-0 \
                   libnss3 libxss1 libxrandr2 libasound2-dev libpangocairo-1.0-0 \
                   libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 gfortran clang \
                   curl mercurial git meson libhdf5-dev pkg-config libopencv-contrib-dev

# Dependencies custom built pyFFTW
RUN apt install -y libfftw3-dev libfftw3-double3 libfftw3-long3 libfftw3-single3 libfftw3-bin

# Python 3.12
RUN apt install -y python3.12 python3.12-venv python3.12-dev

# Create virtualenv in liveuser home
USER liveuser
SHELL ["/bin/bash", "-c"]

# Set up default shell environment
RUN python3 -m venv /home/liveuser/ve312
ENV VIRTUAL_ENV=/home/liveuser/ve312
RUN echo "source /home/liveuser/ve312/bin/activate" >> /home/liveuser/.bashrc
ENV BASH_ENV="/home/liveuser/.bashrc"
#ENV SETUPTOOLS_USE_DISTUTILS "stdlib"
ENV OMP_NUM_THREADS="1"
ENV QT_QPA_PLATFORM="offscreen"
ENV XDG_RUNTIME_DIR="/tmp/runtime-liveuser"

# Rust
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf > rust.sh
RUN sh rust.sh -y
RUN rm rust.sh
RUN echo ". $HOME/.cargo/env" >> /home/liveuser/.bashrc
ENV OPENCV_LINK_LIBS="opencv_core,opencv_imgcodecs,opencv_imgproc,opencv_xphoto"
ENV OPENCV_INCLUDE_PATHS=/usr/include/opencv4

# Nodejs >= 20.0.0
FROM base AS branch-amd64
RUN curl https://nodejs.org/dist/v20.15.1/node-v20.15.1-linux-x64.tar.xz -sSf > node.tar.xz
ENV PATH=/home/liveuser/.cargo/bin:/home/liveuser/ve312/bin:/usr/local/texlive/2024/bin/x86_64-linux:/home/liveuser/node-v20.15.1-linux-x64:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV OPENCV_LINK_PATHS=/usr/lib/x86_64-linux-gnu

FROM base AS branch-arm64
RUN curl https://nodejs.org/dist/v20.15.1/node-v20.15.1-linux-arm64.tar.xz -sSf > node.tar.xz
ENV PATH=/home/liveuser/.cargo/bin:/home/liveuser/ve312/bin:/usr/local/texlive/2024/bin/aarch64-linux:/home/liveuser/node-v20.15.1-linux-arm64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV OPENCV_LINK_PATHS=/usr/lib/aarch64-linux-gnu

FROM branch-${TARGETARCH} AS final

RUN tar -xJf node.tar.xz && rm node.tar.xz

# Install Additionnal Python modules
RUN python -m pip install --upgrade pip setuptools wheel
RUN python -m pip install jupyterlab
RUN python -m ipykernel install --user
RUN jupyter lab build
RUN python -m pip install notebook-as-pdf
RUN pyppeteer-install

RUN python -m pip install maturin meson ninja

# Install custom version of PyFFTW (until a working Py312 version is pushed to PyPI)
RUN git clone https://github.com/jsalort/pyFFTW.git && \
    cd  /home/liveuser/pyFFTW && \
    git switch py312 && \
    python -m pip install /home/liveuser/pyFFTW && \
    rm -fr /home/liveuser/pyFFTW

# Add FluidDyn, FluidLab and FluidImage from Heptapod
RUN hg clone https://foss.heptapod.net/fluiddyn/fluiddyn && \
    cd /home/liveuser/fluiddyn && \
    hg update 6464c4779949 && \
    python -m pip install /home/liveuser/fluiddyn && \
    rm -fr /home/liveuser/fluiddyn

RUN hg clone https://foss.heptapod.net/fluiddyn/fluidlab && \
    python -m pip install ./fluidlab && \
    rm -fr /home/liveuser/fluidlab

RUN python -m pip install transonic setuptools_scm opencv-python scipy

RUN hg clone https://foss.heptapod.net/fluiddyn/fluidimage && \
     cd /home/liveuser/fluidimage && \
     hg update 890d8f622f03 && \
     cat setup.cfg |sed "s,pyfftw >= 0.10.4,pyfftw,g" > setup.cfg && \
     python -m pip install /home/liveuser/fluidimage && \
     rm -fr /home/liveuser/fluidimage
 
# Add pymanip from Github
RUN git clone https://github.com/jsalort/pymanip.git && \
    python -m pip install ./pymanip && \
    rm -fr /home/liveuser/pymanip

# Add pyciv from Gitlab
RUN git clone https://gitlab.salort.eu/jsalort/pyciv.git && \
    python -m pip install /home/liveuser/pyciv && \
    rm -fr /home/liveuser/pyciv
