# zmk-config
My zmk-config's for my keyboards
 - [juriform36](https://github.com/jurica/juriform36)
 - [cloq36](https://github.com/jurica/cloq36)
 - [Humla keyboard](https://github.com/jimmerricks/humla)
 - [platypus split](https://github.com/jurica/platypus)


build commands
docker run -it --rm --workdir /workspaces/zmk -v /home/jb/Dev/kbd/zmk:/workspaces/zmk -v /home/jb/Dev/kbd/zmk-config/:/workspaces/zmk-config -p 3000:3000 zmk /bin/bash

west build -p -d build/humla -b puchi_ble//zmk -- -DSHIELD=humla -DZMK_CONFIG=/workspaces/zmk-config/config

west build -p -d build/platypus_split_left -b xiao_ble//zmk -- -DSHIELD=platypus_split_left -DZMK_CONFIG=/workspaces/zmk-config/config
west build -p -d build/platypus_split_right -b xiao_ble//zmk -- -DSHIELD=platypus_split_right -DZMK_CONFIG=/workspaces/zmk-config/config

west build -p -d build/chocofi_left -b nice_nano//zmk -- -DSHIELD="chocofi_left nice_view_adapter nice_view" -DZMK_CONFIG=/workspaces/zmk-config/config
west build -p -d build/chocofi_right -b nice_nano//zmk -- -DSHIELD="chocofi_right nice_view_adapter nice_view" -DZMK_CONFIG=/workspaces/zmk-config/config

west build -p -d build/chocofi_dongle -b nice_nano//zmk -- -DSHIELD="chocofi_dongle dongle_display" -DZMK_CONFIG=/workspaces/zmk-config/config
west build -p -d build/chocofi_peripheral_left -b nice_nano//zmk -- -DSHIELD="chocofi_left" -DZMK_CONFIG=/workspaces/zmk-config/config -DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n
west build -p -d build/chocofi_peripheral_right -b nice_nano//zmk -- -DSHIELD="chocofi_right" -DZMK_CONFIG=/workspaces/zmk-config/config -DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n

