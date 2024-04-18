#!/bin/bash -eup

if [[ "$#" -ne 1 ]]; then
    echo "ERROR: wrong number of arguments given."
    echo "Usage: ${0} <path to zmk app dir>"
    exit 1
fi

scriptDir="$(dirname "$(realpath "${0}")")"
zmkAppDir="$(realpath "${1}")"
buildYamlFile="${scriptDir}/build.yaml"

cd "${zmkAppDir}"

readarray configs < <(yq -c '.include[]' "${buildYamlFile}")
for config in "${configs[@]}"; do
    board=$(echo "$config" | yq -r '.board')
    shield=$(echo "$config" | yq -r '.shield')
    keyboardName=$(echo "${shield}" | awk '{print $1}')
    west build -d build/"${keyboardName}" -b "${board}" -- -DSHIELD=humla -DZMK_CONFIG="${scriptDir}"/config
done

