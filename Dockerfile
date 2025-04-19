FROM sharelatex/sharelatex:5.3.1-with-texlive-full
LABEL org.opencontainers.image.authors="julien.salort@ens-lyon.fr"

# Install libGL (used by Jupyter lab)
USER root
RUN echo 2025-02-06
RUN apt update && \
    apt install -y libgl1-mesa-dev

# Dependencies for Chromium (used by the betatim/notebook-as-pdf extension)
RUN apt install -y libxcomposite1 libxcursor1 libxi6 libxtst6 libglib2.0-0 \
                   libnss3 libxss1 libxrandr2 libasound2-dev libpangocairo-1.0-0 \
                   libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 gfortran clang \
                   curl mercurial git meson libhdf5-dev pkg-config libopencv-contrib-dev \
                   pandoc

# Dependencies custom built pyFFTW
RUN apt install -y libfftw3-dev libfftw3-double3 libfftw3-long3 libfftw3-single3 libfftw3-bin

# user
USER ubuntu
SHELL ["/bin/bash", "-c"]
WORKDIR /home/ubuntu

# uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN cd /home/ubuntu && . /home/ubuntu/.local/bin/env && \
    uv python install 3.12 && \
    uv venv --python 3.12 /home/ubuntu/.venv/py312

ENV VIRTUAL_ENV=/home/ubuntu/.venv/py312
ENV PKG_CONFIG_PATH=/home/ubuntu/.local/share/uv/python/cpython-3.12.9-linux-x86_64-gnu/lib/pkgconfig
RUN echo "source /home/ubuntu/.venv/py312/bin/activate" >> /home/ubuntu/.bashrc
ENV BASH_ENV="/home/ubuntu/.bashrc"
ENV OMP_NUM_THREADS="1"
ENV QT_QPA_PLATFORM="offscreen"
ENV XDG_RUNTIME_DIR="/tmp/runtime-ubuntu"
ENV PS1="(py312) \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$"
ENV PATH=/home/ubuntu/.venv/py312/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Rust
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf > rust.sh
RUN sh rust.sh -y
RUN rm rust.sh
RUN echo ". $HOME/.cargo/env" >> /home/ubuntu/.bashrc
ENV OPENCV_LINK_LIBS="opencv_core,opencv_imgcodecs,opencv_imgproc,opencv_xphoto"
ENV OPENCV_INCLUDE_PATHS=/usr/include/opencv4,/usr/include/x86_64-linux-gnu/opencv4
ENV OPENCV_LINK_PATHS=/usr/lib/x86_64-linux-gnu
ENV PATH=/home/ubuntu/.cargo/bin:/home/ubuntu/.venv/py312/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install Additionnal Python modules
RUN uv pip install jupyter jupyterlab ipykernel ipympl notebook-as-pdf maturin meson ninja pip tabulate meson-python \
    transonic setuptools_scm opencv-python scipy pyfftw black flake8 pre-commit CoolProp pytest \
    sphinx sphinx-argparse sphinxcontrib-bibtex sphinx_rtd_theme \
    pandas pint numpy_groupies aioftp nbsphinx netcdf4 nptdms openpyxl

RUN python -m ipykernel install --user
RUN jupyter lab build
RUN pyppeteer-install

RUN uv pip install git+https://github.com/jsalort/pymanip.git
RUN uv pip install git+https://gitlab.salort.eu/jsalort/pyciv.git
RUN uv pip install git+https://gitlab.salort.eu/jsalort/asyncsession.git
RUN uv pip install git+https://gitlab.salort.eu/jsalort/imageacquisition.git

ENTRYPOINT [""]

# 2025-02-12: j'ajoute texlive qui manque dans le PATH
ENV PATH=/usr/local/texlive/2024/bin/x86_64-linux:/home/ubuntu/.cargo/bin:/home/ubuntu/.venv/py312/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN mkdir -p /home/ubuntu/.cache/texlive2024
ENV TEXMFHOME=/home/ubuntu/.cache/texlive2024
ENV TEXMFVAR=/home/ubuntu/.cache/texlive2024/texmf-var/
RUN /usr/local/texlive/2024/bin/x86_64-linux/luaotfload-tool -u
