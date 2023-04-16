# This is a Docker file to build a Docker image with ORB-SLAM 3 and all its dependencies pre-installed
# For more info about ORB-SLAM 3 dependencies go check https://github.com/UZ-SLAMLab/ORB_SLAM3
FROM ubuntu:18.04 as base

ARG EIGEN_VERSION=3.3.0
ARG PANGOLIN_VERSION=0.8
ARG OPENCV_VERSION=4.4.0

#-> Install general dependencies
RUN apt-get update && apt-get upgrade -y && \
    #-> Install general usage dependencies
    echo "Installing general usage dependencies ..." && \
    apt-get install -y build-essential cmake apt-file git wget pkg-config && \
    apt-file update && \
    #-> Install python3.8
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install -y python3.8 python3.8-dev python3-pip python3-numpy && \
    python3.8 -m pip install Cython && \
    python3.8 -m pip install numpy && \
    #-> Install Eigen 3 last version
    #-? Needs to be installed BEFORE Pangolin as it also needs Eigen
    #-> Linear algebra library
    echo "Installing Eigen 3 last version ..." && \
    apt-get install -y libeigen3-dev

#-[] Install Pangolin 0.8 version
#-? 3D Vizualisation tool
#-? From : https://cdmana.com/2021/02/20210204202321078t.html
#-? Latest version requires upgrading Eigen
RUN echo "Installing Pangolin dependencies ..." && \
    #-[] Install Pangolin dependencies
    #-? From : https://cdmana.com/2021/02/20210204202321078t.html
    apt-get install -y \
    libglew-dev \
    libboost-dev \
    libboost-thread-dev \
    libboost-filesystem-dev \
    ffmpeg \
    libavutil-dev \
    libpng-dev && \

    echo "Installing Pangolin ${PANGOLIN_VERSION} version ..." && \
    cd opt/ && \
    git clone https://github.com/stevenlovegrove/Pangolin.git Pangolin && \
    cd Pangolin/ && \
    mkdir build && \
    cd build/ && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CPP11_NO_BOOST=1 .. && \
    make -j$(nproc) && \
    make install

#-[] Install OpenCV last version
#-? From : http://techawarey.com/programming/install-opencv-c-c-in-ubuntu-18-04-lts-step-by-step-guide/
#-? Usual computer vision library
RUN echo "Installing OpenCV dependencies ..." && \
    #-[] Install OpenCV dependencies
    #-? From : https://learnopencv.com/install-opencv-3-4-4-on-ubuntu-18-04/
    apt-get install -y \
    libjpeg-dev libpng-dev libtiff-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev gfortran && \
    
    echo "Installing OpenCV last version ..." && \
    cd /opt && \
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz -O opencv-$OPENCV_VERSION.tar.gz && \
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.tar.gz -O opencv_contrib-$OPENCV_VERSION.tar.gz && \
    tar -xzf opencv-$OPENCV_VERSION.tar.gz && \
    tar -xzf opencv_contrib-$OPENCV_VERSION.tar.gz && \
    cd opencv-$OPENCV_VERSION && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D BUILD_PYTHON3=ON \
          -D BUILD_OPENCV_PYTHON2=OFF \
          -D ENABLE_CXX11=ON \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-$OPENCV_VERSION/modules \
          -D BUILD_TIFF=ON \
          -D WITH_CUDA=OFF \
          -D ENABLE_AVX=OFF \
          -D WITH_OPENGL=OFF \
          -D WITH_OPENCL=OFF \
          -D WITH_IPP=OFF \
          -D WITH_TBB=ON \
          -D BUILD_TBB=ON \
          -D WITH_EIGEN=ON \
          -D WITH_V4L=OFF \
          -D WITH_VTK=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D BUILD_SHARED_LIBS=ON \
          -D OPENCV_GENERATE_PKGCONFIG=ON .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

FROM ubuntu:18.04 as builder

# Copy the installed libraries from the base image
COPY --from=base /usr/local /usr/local

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake apt-file git wget pkg-config \
    libeigen3-dev \
    libboost-thread-dev \
    libboost-filesystem-dev \
    libglew-dev \
    ffmpeg \
    libavutil-dev \
    libpng-dev \
    libjpeg-dev libpng-dev libtiff-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev gfortran \
    libssl-dev

COPY . /opt/ORB_SLAM3

RUN echo "Getting ORB-SLAM 3 installation ready ..." && \
    cd /opt/ORB_SLAM3 && \
    ./build.sh

# FROM ubuntu:18.04 as runner
# TODO: can define another image here with already built ORB_SLAM3
# Copy the installed libraries from the base image
# COPY --from=builder /usr/local /usr/local