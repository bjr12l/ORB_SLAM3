#!/bin/bash

thirdparty_components=("DBoW2" "g2o" "Sophus")

for component in "${thirdparty_components[@]}"; do
  echo "Configuring and building Thirdparty/${component} ..."

  cd "Thirdparty/${component}"
  mkdir -p build
  cd build
  cmake -D CMAKE_BUILD_TYPE=Release ..
  make -j$(nproc)

   # Check if the current component is Sophus and install it
  if [ "${component}" == "Sophus" ]; then
    make install
  fi
  
  cd ../../..
done

echo "Uncompress vocabulary ..."

cd Vocabulary
tar -xf ORBvoc.txt.tar.gz
cd ..

echo "Configuring and building ORB_SLAM3 ..."

mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_PREFIX_PATH=/usr ..
make -j$(nproc)
make install
