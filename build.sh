#!/bin/bash -eup

zmkConfigDir="$(dirname "$(realpath "${0}")")"
zmkDir="$(realpath "${zmkConfigDir}/../zmk")"
distDir="$(realpath "${zmkConfigDir}/../dist")"

mkdir -p "$distDir"

# Target registry: name|board|shield|extra_opts
targets=(
    "chocofi_dongle|nice_nano|chocofi_dongle dongle_display|"
    "chocofi_dongle_left|nice_nano|chocofi_left|-DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"
    "chocofi_dongle_right|nice_nano|chocofi_right|-DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"

    "chocofi_left|nice_nano|chocofi_left nice_view_adapter nice_view|"
    "chocofi_right|nice_nano|chocofi_right nice_view_adapter nice_view|"

    "platypus_split_left|xiao_ble|platypus_split_left|"
    "platypus_split_right|xiao_ble|platypus_split_right|"

    "humla|puchi_ble|humla|"

    "juriform36_left|nice_nano|juriform36_left nice_view_adapter nice_view|"
    "juriform36_right|nice_nano|juriform36_right nice_view_adapter nice_view|"

    "cloq36|puchi_ble|cloq36 nice_view_adapter nice_view|"

    "reset_nice_nano|nice_nano|settings_reset|"
    "reset_xiao_ble|xiao_ble|settings_reset|"
    "reset_puchi_ble|puchi_ble|settings_reset|"
)

function target_names {
    local record
    for record in "${targets[@]}"; do
        echo "  ${record%%|*}"
    done
}

function usage {
    echo "Usage: $(basename "$0") [target ...]"
    echo
    echo "With no arguments, builds all targets. Otherwise builds only the named targets."
    echo
    echo "Valid targets:"
    target_names
}

function find_target # name -> prints matching record, or returns 1
{
    local name=$1 record
    for record in "${targets[@]}"; do
        if [[ "${record%%|*}" == "$name" ]]; then
            echo "$record"
            return 0
        fi
    done
    return 1
}

function build_one # zmkDir, zmkConfigDir, board, buildDir, shield, extraOpts
{
    zmkDir=$1
    zmkConfigDir=$2
    board=$3
    buildDir=$4
    shield=$5

    cmd="podman run --rm --workdir /workspaces/zmk/app -v $zmkDir:/workspaces/zmk -v $zmkConfigDir:/workspaces/zmk-config"
    cmd+=" zmk west build -p -d build/$buildDir -b $board//zmk -- -DSHIELD=\"${shield}\" -DZMK_CONFIG=/workspaces/zmk-config/config -DZMK_EXTRA_MODULES=/workspaces/zmk-config"
    if [[ -v 6 && -n $6 ]]; then
        cmd+=" $6"
    fi

    eval "$cmd"
    cp "$zmkDir/app/build/$buildDir/zephyr/zmk.uf2" "$distDir/$buildDir.uf2"
}

# --- target selection ---

selected=()

if [[ $# -eq 0 ]]; then
    selected=("${targets[@]}")
else
    unknown=()
    for arg in "$@"; do
        case $arg in
            -h|--help)
                usage
                exit 0
                ;;
        esac
        if record=$(find_target "$arg"); then
            selected+=("$record")
        else
            unknown+=("$arg")
        fi
    done
    if [[ ${#unknown[@]} -gt 0 ]]; then
        echo "error: unknown target(s): ${unknown[*]}" >&2
        echo >&2
        usage >&2
        exit 1
    fi
fi

for record in "${selected[@]}"; do
    IFS='|' read -r name board shield extra_opts <<< "$record"
    build_one "$zmkDir" "$zmkConfigDir" "$board" "$name" "$shield" "$extra_opts"
done

