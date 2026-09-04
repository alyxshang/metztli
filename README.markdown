# METZTLI

![Metztli CI](https://github.com/alyxshang/metztli/actions/workflows/zig.yml/badge.svg)

***A light and fast library to create CLI apps in Zig.***

## ABOUT

This repository contains the Zig source code for a library to create CLI
applications in Zig. This library is a port of my [Rust library](https://github.com/alyxshang/yue), that does the same. ***Metztli*** is the Nahuatl word for "moon". Nahuatl is the ancient language spoken by the Aztec empire. The code in this library has been linted and has 100% test coverage.

## FEATURES

- Built-in `--help` message.
- Built-in `--version` message.
- Support for the no-minus syntax: `arg`.
- Support for the single minus syntax: `-a`.
- Support for the combined minus syntax: `-ab`.
- Support for the double-minus syntax: `--arg`.
- Support for supplying data to an argument in each of the formats above. 

## INSTALLATION

This Zig library uses Zig version `0.14.0`.
To add this library to your project, use the following command:

```Bash
zig fetch --save git+https://github.com/alyxshang/metztli.git#v.0.1.0
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

This repository features an example CLI app built with ***Metztli***.
The code of this app's `main.zig` is copied verbatim below and has been
heavily commented to understand how to use ***Metztli***.

```Zig
// METZTLI by Alyx Shang.
// Licensed under the FSL v1.

// Importing the "std" namespace.
const std = @import("std");

// Importing the "App" structure from
// Metztli so an app can be built.
const App = @import("metztli").app.App;

pub fn main() !void {

    // Normal GPA.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // Defining the allocator.
    const allocator = gpa.allocator();

    // Creating a buffer for our arguments.
    var args_list = std.ArrayList([*:0]const u8).init(allocator);
    defer args_list.deinit();

    // Getting the actual arguments via the iterator.
    var args_iter = try std.process.argsWithAllocator(allocator);

    // The iterator owns the arguments which is why
    // we do not need to free the strings in the buffer.
    defer args_iter.deinit();
    _ = args_iter.skip();

    // Appending the arguments to our buffer.
    while (args_iter.next()) |arg| {
        try args_list.append(arg);
    }

    // Heap-allocd string for the app's name.
    const name: [*:0]const u8 = allocator.dupeZ(u8, "Test App") catch {
        std.debug.print("Could not create app name.", .{});
        return;
    };

    // Heap-allocd string for the app's author.
    const author: [*:0]const u8 = allocator.dupeZ(u8, "Alyx Shang") catch {
        std.debug.print("Could not create app author.", .{});
        return;
    };

    // Heap-allocd string for the app's version.
    const version: [*:0]const u8 = allocator.dupeZ(u8, "0.1.0") catch {
        std.debug.print("Could not create app version.", .{});
        return;
    };

    // Heap-allocd string for the first argument's name.
    const g_name: [*:0]const u8 = allocator.dupeZ(u8, "greet") catch {
        std.debug.print("Could not create string.", .{});
        return;
    };

    // Heap-allocd string for the first argument's help message.
    const g_help: [*:0]const u8 = allocator.dupeZ(u8, "greets the user") catch {
        std.debug.print("Could not create string.", .{});
        return;
    };

    // Heap-allocd string for the second argument's name.
    const c_name: [*:0]const u8 = allocator.dupeZ(u8, "cgreet") catch {
        std.debug.print("Could not create string.", .{});
        return;
    };

    // Heap-allocd string for the second argument's help message.
    const c_help: [*:0]const u8 = allocator.dupeZ(u8, "greets the user with their name") catch {
        std.debug.print("Could not create string.", .{});
        return;
    };

    // Heap-allocd string for the version argument's name.
    const v_name: [*:0]const u8 = allocator.dupeZ(u8, "version") catch {
        std.debug.print("Could not create string.", .{});
        return;
    };

    // Heap-allocd string for the version argument's help message.
    const v_help: [*:0]const u8 = allocator.dupeZ(u8, "displays version info") catch {
        std.debug.print("Could not create string.", .{});
        return;
    };

    // Heap-allocd string for the help argument's name.
    const h_name: [*:0]const u8 = allocator.dupeZ(u8, "help") catch {
        std.debug.print("Could not create string.", .{});
        return;
    };

    // Heap-allocd string for the help argument's help message.
    const h_help: [*:0]const u8 = allocator.dupeZ(u8, "displays help info") catch {
        std.debug.print("Could not create string.", .{});
        return;
    };

    // And finally our app. The
    // app now owns the three 
    // strings.
    var app: App = App.init(
        allocator,
        name,
        author,
        version
    );

    // We must free resources once
    // we're done.
    defer app.deinit();

    // Setting the first argument. Note the use of "false"
    // since this argument does NOT accept data.
    app.setArg(false, g_name, g_help) catch {
        std.debug.print("Could not set the \"greet\" argument.\n", .{});
        return;
    };

    // Setting the version argument. Note the use of "false"
    // since this argument does NOT accept data.
    app.setArg(false, v_name, v_help) catch {
        std.debug.print("Could not set the \"version\" argument.\n", .{});
        return;
    };

    // Setting the help argument. Note the use of "false"
    // since this argument does NOT accept data.
    app.setArg(false, h_name, h_help) catch {
        std.debug.print("Could not set the \"help\" argument.\n", .{});
        return;
    };

    // Setting the second argument. Note the use of "true"
    // since this argument DOES accept data.
    app.setArg(true, c_name, c_help) catch {
        std.debug.print("Could not set the \"cgreet\" argument.\n", .{});
        return;
    };

    // Now we feed our app the argument buffer
    // and attempt to parse the received strings.
    app.parseArgs(&args_list) catch {
        std.debug.print("Could not parse arguments.\n", .{});
        return;
    };

    // Checking if both arguments have been used.
    if (app.argUsed("greet") and app.argUsed("cgreet")){
        std.debug.print("Both at the same time? Why?\n", .{});
    }

    // Checking if the "greet" argument has been used.
    else if (app.argUsed("greet")){
        std.debug.print("Hello World.\n", .{});
    }

    // Checking if the "version" argument has been used.
    else if (app.argUsed("version")){
        const version_str = app.versionInfo() catch {
            std.debug.print("Could not get version info.\n", .{});
            return;
        };
        defer allocator.free(std.mem.span(version_str));
        std.debug.print("{s}", .{version_str});
    }

    // Checking if the "help" argument has been used.
    else if (app.argUsed("help")){
        const help_str = app.helpInfo() catch {
            std.debug.print("Could not get help info.\n", .{});
            return;
        };
        defer allocator.free(std.mem.span(help_str));
        std.debug.print("{s}", .{help_str});
    }

    // Checking if the "cgreet" version argument has been used.
    else if (app.argUsed("cgreet")){

        // We fetch supplied data, if it was supplied
        // and handle any errors.
        const data = app.getArgData("cgreet") catch {
            std.debug.print("No data for \"cgreet\" supplied.\n", .{});
            return;
        };
        defer allocator.free(std.mem.span(data));
        std.debug.print("Hello, {s}!\n", .{data});
    }

    // Graceful nonsense option handling.
    else {

        // In any other case, we generate the help message
        // and print it out.
        const help = app.helpInfo() catch {
            std.debug.print("Could not build help message.", .{});
            return;
        };
        defer allocator.free(std.mem.span(help));
        std.debug.print("{s}", .{help});
    }
}
```

Please note that ***Metztli*** only accepts the collected array of arguments
supplied without the name of the exectuable being the first item in
the array of arguments. More information on the entities inside this library 
can be obtained by cloning this repository and running the `zig build docs` 
command from the repository's root. To run the example, change directory
into the `example` directory and run the `zig build run -- --help`
command.

## CHANGELOG

### Version 0.1.0

- Initial release.
- Upload to GitHub.

## NOTE

- *Metztli* by *Alyx Shang*.
- Licensed under the [FSL v1](https://alyxshang.boo/fair-software-license).
