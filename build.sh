#!/bin/bash -eup

scriptDir="$(dirname "$(realpath "${0}")")"
zmkAppDir="$(realpath "${scriptDir}/../zmk/app")"
buildYamlFile="${scriptDir}/build.yaml"

cd "${zmkAppDir}"

readarray configs < <(yq -c '.include[]' "${buildYamlFile}")
for config in "${configs[@]}"; do
    board=$(echo "$config" | yq -r '.board')
    shield=$(echo "$config" | yq -r '.shield')
    keyboardName=$(echo "${shield}" | awk '{print $1}')
    west build -p -d build/"${keyboardName}" -b "${board}" -- -DSHIELD="${shield}" -DZMK_CONFIG="${scriptDir}"/config
done

