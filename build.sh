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
    echo "With no target, targets are picked from an interactive checklist"
    echo "(fzf if available, otherwise a numbered fallback list)."
    echo "\"all\" is a special target that builds every target."
    echo "Otherwise builds only the named targets."
    echo
    echo "Options:"
    echo "  -h, --help         show this help"
    echo
    echo "Valid targets:"
    echo "  all (special target: build everything)"
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

function select_targets_interactive # out array name -> fills it with selected records
{
    local -n out=$1
    local names=() record name
    for record in "${targets[@]}"; do
        names+=("${record%%|*}")
    done

    if command -v fzf >/dev/null 2>&1; then
        local picked
        if ! picked=$(printf '%s\n' "${names[@]}" |
            fzf --multi --prompt='build> ' --header='tab: toggle  enter: build  esc: cancel'); then
            echo "cancelled." >&2
            exit 130
        fi
        out=()
        if [[ -n $picked ]]; then
            while IFS= read -r name; do
                record=$(find_target "$name")
                out+=("$record")
            done <<< "$picked"
        fi
        return 0
    fi

    # Fallback checklist for terminals without fzf
    local total=${#targets[@]}
    local checked=() i tok input msg=""
    for ((i = 0; i < total; i++)); do
        checked[i]=1
    done

    while true; do
        if [[ -t 1 ]]; then
            clear
        fi
        if [[ -n $msg ]]; then
            echo "$msg"
            echo
        fi
        echo "Select targets to build:"
        for i in "${!targets[@]}"; do
            if (( checked[i] )); then
                echo "  [x] $((i + 1)) ${names[i]}"
            else
                echo "  [ ] $((i + 1)) ${names[i]}"
            fi
        done
        echo
        echo "toggle: numbers or ranges (e.g. 3, \"1 5\", \"2-4\") | a: all | n: none | enter: build | q: quit"
        read -rp "selection> " input || exit 0
        msg=""
        case $input in
            "") break ;;
            q) exit 0 ;;
            a)
                for ((i = 0; i < total; i++)); do checked[i]=1; done
                ;;
            n)
                for ((i = 0; i < total; i++)); do checked[i]=0; done
                ;;
            *)
                for tok in $input; do
                    if [[ $tok =~ ^([0-9]+)-([0-9]+)$ ]]; then
                        local from=${BASH_REMATCH[1]} to=${BASH_REMATCH[2]} t
                        for ((t = from; t <= to; t++)); do
                            if (( t >= 1 && t <= total )); then
                                checked[t-1]=$((1 - checked[t-1]))
                            fi
                        done
                    elif [[ $tok =~ ^[0-9]+$ ]]; then
                        if (( tok >= 1 && tok <= total )); then
                            checked[tok-1]=$((1 - checked[tok-1]))
                        else
                            msg="no such target: $tok"
                        fi
                    else
                        msg="ignored: $tok"
                    fi
                done
                ;;
        esac
    done

    out=()
    for i in "${!targets[@]}"; do
        if (( checked[i] )); then
            out+=("${targets[i]}")
        fi
    done
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

positional=()
unknown_opts=()
unknown=()

for arg in "$@"; do
    case $arg in
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            unknown_opts+=("$arg")
            ;;
        *)
            positional+=("$arg")
            ;;
    esac
done

if [[ ${#unknown_opts[@]} -gt 0 ]]; then
    echo "error: unknown option(s): ${unknown_opts[*]}" >&2
    echo >&2
    usage >&2
    exit 1
fi

selected=()

if [[ ${#positional[@]} -eq 0 ]]; then
    # interactive is the default when no target is given
    select_targets_interactive selected
    if [[ ${#selected[@]} -eq 0 ]]; then
        echo "no targets selected, nothing to do."
        exit 0
    fi
else
    build_all=0
    for arg in "${positional[@]}"; do
        if [[ $arg == "all" ]]; then
            build_all=1
        elif record=$(find_target "$arg"); then
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
    if [[ $build_all -eq 1 ]]; then
        selected=("${targets[@]}")
    fi
fi

for record in "${selected[@]}"; do
    IFS='|' read -r name board shield extra_opts <<< "$record"
    build_one "$zmkDir" "$zmkConfigDir" "$board" "$name" "$shield" "$extra_opts"
done

