#!/usr/bin/env bash

if [ "${BINSTAR_TOKEN}" ]; then
  export UPLOAD="--upload-channels odm2"
else
  export UPLOAD=""
fi

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
UPLOAD_OWNER="odm2"
IMAGE_NAME="ocefpaf/conda-recipes:latest_x64"

config=$(cat <<CONDARC

channels:
 - ${UPLOAD_OWNER}
 - defaults

show_channel_urls: True

CONDARC
)

cat << EOF | docker run -i \
                        -v ${REPO_ROOT}:/conda-recipes \
                        -a stdin -a stdout -a stderr \
                        $IMAGE_NAME \
                        bash || exit $?

if [ "${BINSTAR_TOKEN}" ];then
    echo
    export BINSTAR_TOKEN=${BINSTAR_TOKEN}
fi

export PYTHONUNBUFFERED=1
echo "$config" > ~/.condarc

conda config --set always_yes yes --set changeps1 no --set show_channel_urls true --set auto_update_conda false
# We cannot use modern conda/conda-build/conda-build-all
# unless we move to a distributed model or implement a
# conda_build_config.yaml.
conda install conda-build-all conda-build=2 conda=4.2.16

# A lock sometimes occurs with incomplete builds.
conda clean --lock

conda info

conda-build-all /conda-recipes/recipes $UPLOAD --inspect-channels $UPLOAD_OWNER --matrix-conditions "python >=2.7,<3|>3.5,<=3.6"

EOF
