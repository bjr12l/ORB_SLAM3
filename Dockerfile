# This is a Docker file to build a Docker image with ORB-SLAM 3 and all its dependencies pre-installed
# For more info about ORB-SLAM 3 dependencies go check https://github.com/UZ-SLAMLab/ORB_SLAM3
FROM ubuntu:18.04

ARG EIGEN_VERSION=3.3.0
ARG PANGOLIN_VERSION=0.8
ARG OPENCV_VERSION=4.4.0

#-> Install general dependencies
RUN apt-get update && apt-get upgrade && \
    #-> Install general usage dependencies
    echo "Installing general usage dependencies ..." && \
    apt-get install -y build-essential cmake apt-file git wget pkg-config && \
    apt-file update

#-[] Install Eigen 3.3.0 version
#-? Needs to be installed BEFORE Pangolin as it also needs Eigen
#-? Linear algebra library
#-? Bulid crashes further down the line with version > 3.3.0 TODO: update README and Cmake
RUN echo "Installing Eigen ${EIGEN_VERSION} version ..." && \
    cd /opt && \
    wget https://gitlab.com/libeigen/eigen/-/archive/$EIGEN_VERSION/eigen-$EIGEN_VERSION.tar.gz && \
    tar -xzf eigen-$EIGEN_VERSION.tar.gz && \
    cd eigen-$EIGEN_VERSION && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE .. && \
    make install && \
    cd ../../ && \
    rm -rf eigen-$EIGEN_VERSION/ eigen-$EIGEN_VERSION.tar.gz

#-[] Install Pangolin 0.6 version
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

    echo "Installing Pangolin last version ..." && \
    cd /opt && \
    wget https://github.com/stevenlovegrove/Pangolin/archive/refs/tags/v$PANGOLIN_VERSION.tar.gz -O Pangolin.tar.gz && \
    tar -xzf Pangolin.tar.gz && \
    cd Pangolin-$PANGOLIN_VERSION/ && \
    mkdir build && \
    cd build/ && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CPP11_NO_BOOST=1 .. && \
    make -j$(nproc) && \
    make install && \
    cd ../../ && \
    rm -rf Pangolin-$PANGOLIN_VERSION/ Pangolin.tar.gz


#-[] Install OpenCV last version
#-? From : http://techawarey.com/programming/install-opencv-c-c-in-ubuntu-18-04-lts-step-by-step-guide/
#-? Another RUN command in order to free memory
#-? Usual computer vision library
RUN echo "Installing OpenCV dependencies ..." && \
    #-[] Install OpenCV dependencies
    #-? From : https://learnopencv.com/install-opencv-3-4-4-on-ubuntu-18-04/
    apt-get install -y \
    ffmpeg \
    gstreamer1.0-plugins-base \
    libgtk-3-dev \
    libjasper-dev \
    libjpeg-turbo8-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    v4l-utils \
    libxine2-dev
    
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
          -D OPENCV_GENERATE_PKGCONFIG=ON .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd ../.. && \
    rm -rf opencv-$OPENCV_VERSION/ opencv_contrib-$OPENCV_VERSION/ opencv-$OPENCV_VERSION.tar.gz opencv_contrib-$OPENCV_VERSION.tar.gz

COPY . /opt/ORB_SLAM3/

RUN echo "Getting ORB-SLAM 3 installation ready ..." && \
    cd /opt/ORB_SLAM3 && \
    ./build.sh
