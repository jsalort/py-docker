FROM jsalort/texlive2020:latest
MAINTAINER Julien Salort, julien.salort@ens-lyon.fr

# Install libGL (used by Jupyter lab)
USER root
RUN apt update && \
    apt install -y libgl1-mesa-dev

# Dependencies for Chromium (used by the betatim/notebook-as-pdf extension)
RUN apt install -y libxcomposite1 libxcursor1 libxi6 libxtst6 libglib2.0-0 \
                   libnss3 libxss1 libxrandr2 libasound2 libpangocairo-1.0-0 \
                   libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0

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
    conda create -n py38 -c conda-forge python=3.8 && \
    conda activate py38 && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda env update --file py38.yml && \
    python -m ipykernel install --user && \
    jupyter lab build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyter-matplotlib && \
    python -m pip install notebook-as-pdf && \
    pyppeteer-install

RUN rm -f Anaconda3-2020.02-Linux-x86_64.sh py38.yml

# Temporary work-around nc-config problem in conda-forge
USER root
RUN mkdir -p /home/conda/feedstock_root/build_artifacts/netcdf-fortran_1585602845013/_build_env && \
    ln -s /home/liveuser/anaconda3/envs/py38/bin /home/conda/feedstock_root/build_artifacts/netcdf-fortran_1585602845013/_build_env/bin
USER liveuser

## Set up default shell environment
#RUN echo "conda activate py38" >> /home/liveuser/.bashrc
#ENV BASH_ENV "/home/liveuser/.bashrc"
#
#ENTRYPOINT ["/bin/bash", "-c"]
#CMD ["/bin/bash"]

# Set environment similar to what conda activate does
# RUN rm .bashrc
ENV AS "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-as"
ENV LDFLAGS "-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,-rpath,/home/liveuser/anaconda3/envs/py38/lib -Wl,-rpath-link,/home/liveuser/anaconda3/envs/py38/lib -L/home/liveuser/anaconda3/envs/py38/lib"
ENV AR "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-ar"
ENV MANPATH "/usr/local/texlive/2020/texmf-dist/doc/man:"
ENV GCC_NM "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gcc-nm"
ENV NM "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-nm"
ENV CPPFLAGS "-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem /home/liveuser/anaconda3/envs/py38/include"
ENV CONDA_SHLVL "2"
ENV CONDA_PROMPT_MODIFIER "(py38)" 
ENV SIZE "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-size"
ENV GFORTRAN "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gfortran"
ENV CONDA_BACKUP_HOST "x86_64-conda_cos6-linux-gnu"
ENV CONDA_EXE "/home/liveuser/anaconda3/bin/conda"
ENV DEBUG_FORTRANFLAGS "-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /home/liveuser/anaconda3/envs/py38/include -fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe"
ENV CXXFLAGS "-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /home/liveuser/anaconda3/envs/py38/include"
ENV LD_GOLD "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-ld.gold"
ENV CONDA_BUILD_SYSROOT "/home/liveuser/anaconda3/envs/py38/x86_64-conda_cos6-linux-gnu/sysroot"
ENV STRINGS "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-strings"
ENV CPP "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-cpp"
ENV _CE_CONDA ""
ENV CXXFILT "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-c++filt"
ENV CONDA_PREFIX_1 "/home/liveuser/anaconda3"
ENV PATH "/home/liveuser/anaconda3/envs/py38/bin:/home/liveuser/anaconda3/condabin:/usr/local/texlive/2020/bin/x86_64-linux:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV DEBUG_CXXFLAGS "-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem /home/liveuser/anaconda3/envs/py38/include"
ENV LD "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-ld"
ENV CONDA_PREFIX "/home/liveuser/anaconda3/envs/py38"
ENV F90 "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gfortran"
ENV STRIP "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-strip"
ENV ELFEDIT "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-elfedit"
ENV F95 "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-f95"
ENV GCC_RANLIB "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gcc-ranlib"
ENV DEBUG_FFLAGS "-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /home/liveuser/anaconda3/envs/py38/include -fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe"
ENV F77 "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gfortran"
ENV CXX "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-c++"
ENV _CE_M ""
ENV OBJCOPY "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-objcopy"
ENV SHLVL "2"
ENV FORTRANFLAGS "-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /home/liveuser/anaconda3/envs/py38/include"
ENV DEBUG_CPPFLAGS "-D_DEBUG -D_FORTIFY_SOURCE=2 -Og -isystem /home/liveuser/anaconda3/envs/py38/include"
ENV CFLAGS "-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /home/liveuser/anaconda3/envs/py38/include"
ENV FC "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gfortran"
ENV _CONDA_PYTHON_SYSCONFIGDATA_NAME "_sysconfigdata_x86_64_conda_cos6_linux_gnu"
ENV GCC "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gcc"
ENV ADDR2LINE "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-addr2line"
ENV CONDA_PYTHON_EXE "/home/liveuser/anaconda3/bin/python"
ENV CONDA_DEFAULT_ENV "py38"
ENV DEBUG_CFLAGS "-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem /home/liveuser/anaconda3/envs/py38/include"
ENV RANLIB "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-ranlib"
ENV INFOPATH "/usr/local/texlive/2020/texmf-dist/doc/info:"
ENV CMAKE_PREFIX_PATH "/home/liveuser/anaconda3/envs/py38:/home/liveuser/anaconda3/envs/py38/x86_64-conda_cos6-linux-gnu/sysroot/usr"
ENV CC "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-cc"
ENV READELF "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-readelf"
ENV GCC_AR "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gcc-ar"
ENV OBJDUMP "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-objdump"
ENV GPROF "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-gprof"
ENV GXX "/home/liveuser/anaconda3/envs/py38/bin/x86_64-conda_cos6-linux-gnu-g++"
ENV FFLAGS "-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /home/liveuser/anaconda3/envs/py38/include"
