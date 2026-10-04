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

Firmware files are output to `../dist`.

### One-time setup

> [!IMPORTANT]
> The build image is configured in build.sh, see podmanImage. It has to match zmks [default](https://github.com/zmkfirmware/zmk/blob/main/.devcontainer/Dockerfile).

Before the first build (and after changes to `config/west.yml`), set up the
west workspace at `../zmk-workspace`. This creates the workspace from
`config/west.yml` and fetches all projects (zmk, zephyr, modules) into it:

```bash
./build.sh setup
```

Everything west touches outside this repo lives in that single folder; it can
be deleted and recreated with `./build.sh setup` at any time.

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
