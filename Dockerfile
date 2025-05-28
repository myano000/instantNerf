FROM jhagege/docker-ubuntu-vnc-desktop-with-cuda

USER root

# Update package list
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN apt-get update


# Install basic development tools
RUN apt-get  install -y \
    libssl-dev \
    git

# Install graphics libraries
RUN apt-get  install -y \
    libopenexr-dev \
    libxi-dev \
    libglfw3-dev \
    libglew-dev \
    libxinerama-dev \
    libxcursor-dev

# Install Boost libraries
RUN apt-get  install -y \
    libboost-program-options-dev \
    libboost-filesystem-dev \
    libboost-graph-dev \
    libboost-system-dev \
    libboost-test-dev

# Install numerical computation libraries
RUN apt-get  install -y \
    libeigen3-dev \
    libsuitesparse-dev \
    libatlas-base-dev

# Install image processing libraries
RUN apt-get  install -y \
    libfreeimage-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev

# Install cmake recent version
RUN wget https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2.tar.gz && \
      tar xzf cmake-3.22.2.tar.gz && \
      cd cmake-3.22.2 && \
      ./bootstrap && make && make install && \
      cd /root

# Install flags libraries
RUN apt-get  install -y \
    libgflags-dev

# Install glog from source
RUN cd /root && \
    git clone https://github.com/google/glog.git && \
    cd glog && \
    git checkout v0.6.0 && \
    mkdir build && \
    cd build && \
    cmake .. -DBUILD_SHARED_LIBS=ON \
             -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install && \
    cd /root

# Install Python related packages
RUN apt-get install -y \
    python3-pip \
    python3-dev

RUN pip install numpy pyexr pillow scipy opencv-python


# Install instant-ngp
# If GPU autodetection fails, set the enviroment variable TCNN_CUDA_ARCHITECTURES
# with the GPU's compute capabirity code.
# ENV TCNN_CUDA_ARCHITECTURES 75
RUN git clone --recursive https://github.com/nvlabs/instant-ngp && \
    cd instant-ngp && \
    cmake . -B build && \
    cmake --build build --config RelWithDebInfo -j 16 && \
    cd /root

RUN apt-get install -y \
    build-essential \
    gcc \
    g++ \
    gfortran

RUN apt-get install -y \
    libtbb-dev \
    libatlas-base-dev \
    libsuitesparse-dev

RUN apt-get install -y libmetis-dev

# abseilライブラリをインストール
# abseilライブラリをソースからビルド
RUN cd /root && \
    git clone https://github.com/abseil/abseil-cpp.git && \
    cd abseil-cpp && \
    git checkout 20230125.3 && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
             -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install




RUN git clone https://ceres-solver.googlesource.com/ceres-solver && \
    cd ceres-solver && \
    git checkout $(git describe --tags) && \
    mkdir build && \
    cd build && \
    cmake .. -DBUILD_TESTING=OFF \
             -DBUILD_EXAMPLES=OFF \
             -DCMAKE_BUILD_TYPE=Release \
             -DBUILD_SHARED_LIBS=ON \
             -DCMAKE_PREFIX_PATH="/usr/local" && \
    make -j$(nproc) && \
    make install && \
    ldconfig





# Install COLMAP 3.7
RUN wget https://github.com/colmap/colmap/archive/refs/tags/3.7.tar.gz && \
    tar xzf 3.7.tar.gz && \
    cd colmap-3.7 && \
    mkdir build && \
    cd build && \
    cmake .. \
          -DCMAKE_PREFIX_PATH="/usr/local" \
          -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install && \
    cd /root && \
    ldconfig

ENV PATH="/usr/local/cuda-11.2/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.2/lib64:$LD_LIBRARY_PATH"
