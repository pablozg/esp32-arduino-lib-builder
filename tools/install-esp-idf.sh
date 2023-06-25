#/bin/bash

source ./tools/config.sh

if ! [ -x "$(command -v $SED)" ]; then
  	echo "ERROR: $SED is not installed! Please install $SED first."
  	exit 1
fi

#
# CLONE ESP-IDF
#

if [ ! -d "$IDF_PATH" ]; then
	echo "ESP-IDF is not installed! Installing from $IDF_REPO_URL branch $IDF_BRANCH"
	git clone $IDF_REPO_URL -b $IDF_BRANCH
	idf_was_installed="1"
fi

if [ "$IDF_TAG" ]; then
    git -C "$IDF_PATH" checkout "tags/$IDF_TAG"
    idf_was_installed="1"
elif [ "$IDF_COMMIT" ]; then
		echo " path $IDF_PATH commit $IDF_COMMIT"
    git -C "$IDF_PATH" checkout "$IDF_COMMIT"
    commit_predefined="1"
fi

#
# UPDATE ESP-IDF TOOLS AND MODULES
#

if [ ! -x $idf_was_installed ] || [ ! -x $commit_predefined ]; then
	git -C $IDF_PATH submodule update --init --recursive
	$IDF_PATH/install.sh
fi

#
# Arduino needs cam_hal.h from esp32-camera in include folder
#

cp "$IDF_PATH/components/esp32-camera/driver/private_include/cam_hal.h" "$IDF_PATH/components/esp32-camera/driver/include/"

#
# SETUP ESP-IDF ENV
#

source $IDF_PATH/export.sh
export IDF_COMMIT=$(git -C "$IDF_PATH" rev-parse --short HEAD)
export IDF_BRANCH=$(git -C "$IDF_PATH" symbolic-ref --short HEAD || git -C "$IDF_PATH" tag --points-at HEAD)
