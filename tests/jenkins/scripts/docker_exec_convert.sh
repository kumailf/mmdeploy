#!/bin/bash

## func

function getFullName() {
    local codebase_=$1
    codebase_fullname=""
    if [ "$codebase_" = "mmdet" ]; then codebase_fullname="mmdetection"; fi 
    if [ "$codebase_" = "mmcls" ]; then codebase_fullname="mmclassification"; fi 
    if [ "$codebase_" = "mmdet3d" ]; then codebase_fullname="mmdetection3d"; fi 
    if [ "$codebase_" = "mmedit" ]; then codebase_fullname="mmediting"; fi 
    if [ "$codebase_" = "mmocr" ]; then codebase_fullname="mmocr"; fi 
    if [ "$codebase_" = "mmpose" ]; then codebase_fullname="mmpose"; fi 
    if [ "$codebase_" = "mmrotate" ]; then codebase_fullname="mmrotate"; fi 
    if [ "$codebase_" = "mmseg" ]; then codebase_fullname="mmsegmentation"; fi 
}

## parameters
export codebase=$1
getFullName $codebase
# backends=$2

## clone ${codebase}
cd /root/workspace
git clone https://github.com/open-mmlab/${codebase_fullname}.git

## build mmdeploy
cd mmdeploy
mkdir -p builde
cd build
cmake .. -DMMDEPLOY_BUILD_SDK=ON -DMMDEPLOY_BUILD_EXAMPLES=ON \
        -DMMDEPLOY_BUILD_SDK_MONOLITHIC=ON -DMMDEPLOY_BUILD_TEST=ON \
        -DMMDEPLOY_BUILD_SDK_PYTHON_API=ON -DMMDEPLOY_BUILD_SDK_JAVA_API=ON \
        -DMMDEPLOY_BUILD_EXAMPLES=ON -DMMDEPLOY_ZIP_MODEL=ON \
        -DMMDEPLOY_TARGET_BACKENDS="ort;pplnn;openvino;ncnn" \
        -DMMDEPLOY_SHARED_LIBS=OFF \
        -DONNXRUNTIME_DIR=${ONNXRUNTIME_DIR} \
        -DPPLNN_DIR=${PPLNN_DIR} 

make -j $(nproc) && make install
cd ../
conda init bash

## start convert
for TORCH_VERSION in 1.8.0 1.9.0 1.10.0 1.11.0 1.12.0
do
    /opt/conda/envs/torch${TORCH_VERSION}/bin/pip install -v -e .
    /opt/conda/envs/torch${TORCH_VERSION}/bin/pip install -r requirements/tests.txt
    ## build ${codebase}
    /opt/conda/envs/torch${TORCH_VERSION}/bin/mim install ${codebase}

    ## start regression  
    conda run --name torch${TORCH_VERSION} "
        python ./tools/regression_test.py \
            --codebase ${codebase} \
            --work-dir "../mmdeploy_regression_working_dir/${codebase}/torch${TORCH_VERSION}" > convert.log
    "


done