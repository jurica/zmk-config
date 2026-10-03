# zmk-config
My zmk-config's for my keyboards
 - [juriform36](https://github.com/jurica/juriform36)
 - [cloq36](https://github.com/jurica/cloq36)
 - [Humla keyboard](https://github.com/jimmerricks/humla)
 - [platypus split](https://github.com/jurica/platypus)
 - [chocofi](https://github.com/pashutk/chocofi)

## Building

build.sh uses podman to build firmware in a container. It expects:
- podman installed
- a cloned and setup zmk repo in the parent folder (`../zmk`)

Firmware files are output to `../dist`.

### Usage

Run without arguments for interactive target selection (uses fzf if available):
```bash
./build.sh
```

Build specific targets:
```bash
./build.sh chocofi_left chocofi_right
```

Build all targets:
```bash
./build.sh all
```

Show help:
```bash
./build.sh -h
```

Check official setup docs for more details: https://zmk.dev/docs/development/local-toolchain/setup/container
