#!/bin/bash -eup

zmkConfigDir="$(dirname "$(realpath "${0}")")"
zmkDir="$(realpath "${zmkConfigDir}/../zmk")"
distDir="$(realpath "${zmkConfigDir}/../dist")"

mkdir -p $distDir

function build_one # zmkDir, zmkConfigDir, board, buildDir, shield, extraOpts
{
    zmkDir=$1
    zmkConfigDir=$2
    board=$3
    buildDir=$4
    shield=$5

    cmd="podman run --rm --workdir /workspaces/zmk/app -v $zmkDir:/workspaces/zmk -v $zmkConfigDir:/workspaces/zmk-config"
    cmd+=" zmk west build -p -d build/$buildDir -b $board//zmk -- -DSHIELD=\"${shield}\" -DZMK_CONFIG=/workspaces/zmk-config/config -DZMK_EXTRA_MODULES=/workspaces/zmk-config"
    if [[ -v 6 ]];then
        cmd+=" $6"
    fi

    eval $cmd
    cp $zmkDir/app/build/$buildDir/zephyr/zmk.uf2 $distDir/$buildDir.uf2
}

build_one $zmkDir $zmkConfigDir "nice_nano" "chocofi_dongle" "chocofi_dongle dongle_display"
build_one $zmkDir $zmkConfigDir "nice_nano" "chocofi_dongle_left"  "chocofi_left"  "-DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"
build_one $zmkDir $zmkConfigDir "nice_nano" "chocofi_dongle_right" "chocofi_right" "-DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"

build_one $zmkDir $zmkConfigDir "nice_nano" "chocofi_left"  "chocofi_left nice_view_adapter nice_view"
build_one $zmkDir $zmkConfigDir "nice_nano" "chocofi_right" "chocofi_right nice_view_adapter nice_view"

build_one $zmkDir $zmkConfigDir "xiao_ble" "platypus_split_left" "platypus_split_left"
build_one $zmkDir $zmkConfigDir "xiao_ble" "platypus_split_right" "platypus_split_right"

build_one $zmkDir $zmkConfigDir "puchi_ble" "humla" "humla"

build_one $zmkDir $zmkConfigDir "nice_nano" "juriform36_left"  "juriform36_left nice_view_adapter nice_view"
build_one $zmkDir $zmkConfigDir "nice_nano" "juriform36_right" "juriform36_right nice_view_adapter nice_view"

build_one $zmkDir $zmkConfigDir "puchi_ble" "cloq36" "cloq36 nice_view_adapter nice_view"

build_one $zmkDir $zmkConfigDir "nice_nano" "reset_nice_nano" "settings_reset"
build_one $zmkDir $zmkConfigDir "xiao_ble" "reset_xiao_ble" "settings_reset"
build_one $zmkDir $zmkConfigDir "puchi_ble" "reset_puchi_ble" "settings_reset"

