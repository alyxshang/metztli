# METZTLI

![Metztli CI](https://github.com/alyxshang/metztli/actions/workflows/zig.yml/badge.svg)

***A lightweight library for parsing command line arguments in Zig.***

## ABOUT

This repository contains the Zig source code of a library for parsing command line arguments. 
*Metztli* is the Nahuatl word for "moon".

## FEATURES

- Built-in `--help` message.
- Built-in `--version` message.
- Support for the no-minus syntax: `arg`.
- Support for the single minus syntax: `-a`.
- Support for the combined minus syntax: `-ab`.
- Support for the double-minus syntax: `--arg`.
- Support for supplying data to an argument in all of the formats above. 

## INSTALLATION

This Zig library uses Zig version `0.17.0`.
To add this library to your project, use the following command:

```Bash
zig fetch --save git+https://github.com/alyxshang/metztli.git#v.0.2.0
```

The following module must also be declared in your project's `build.zig`:

```Zig
const metztli_dep = b.dependency(
    "metztli", 
    .{
        .target = target,
        .optimize = optimize,
    }
);
your_main_module.root_module.addImport("metztli", metztli_dep.module("metztli"));
```

`your_main_module` is the module you want to add *Metztli* to.

## USAGE

This repository features an example CLI app built with *Metztli*.
The code of the example app's `main.zig` can be found [here](example/src/main.zig)
The file has been commented to understand how to use *Metztli*.
To run the example, change directory into the `example` directory and run the 
`zig build run -- --help` command.

Important note: *Metztli* accepts the array collected from `std.process.Init`,
which features the name of your executable as the first item. This library, however,
only accepts this array with the executable name removed. 

More information on the entities inside this library can be obtained by cloning this 
repository and running the `zig build docs` command from the repository's root.

## CHANGELOG

### Version 0.1.0

- Initial release.
- Upload to GitHub.

## Version 0.2.0

- Improved documentation.
- Migrated *Metztli* to Zig v.0.17.0.

## NOTE

- *Metztli* by *Alyx Shang*.
- Licensed under the [FSL v1](https://alyxshang.boo/content/fair-software-license).
