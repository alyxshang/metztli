// METZTLI by Alyx Shang.
// Licensed under the FSL v1.

// Importing the "std" namespace.
const std = @import("std");

// Importing the module containing
// the main "App" structure.
const app = @import("app.zig");

// Importing the module containing
// structures and functions to work
// with set arguments.
const arg = @import("arg.zig");

// Importing the module containing
// a function to deserialize tokens.
const des = @import("des.zig");

// Importing the module containing
// the functions to build the help
// message for an app.
const help = @import("help.zig");

// Importing the module containing
// utility functions to test it.
const utils = @import("utils.zig");

// Importing the module containing
// the tokenizer to test it.
const lexer = @import("lexer.zig");

// Importing the module containing
// the parser to test it.
const parser = @import("parser.zig");

// Testing the module containing utility functions.
test "Testing the module containing utility functions." {
    const test_str: [*:0]const u8 =
        try std.testing.allocator.dupeZ(u8, "hello");
    errdefer std.testing.allocator.free(std.mem.span(test_str));
    defer std.testing.allocator.free(std.mem.span(test_str));
    const len: u64 = utils.strLen(test_str);
    const cloned: [*:0]const u8 = try utils.cloneSlice(
        test_str,
        std.testing.allocator
    );
    errdefer std.testing.allocator.free(std.mem.span(cloned));
    defer std.testing.allocator.free(std.mem.span(cloned));
    const cloned_len: u64 = utils.strLen(cloned);
    const removed: [*:0]const u8 = try utils.removeAt(0, cloned, std.testing.allocator);
    errdefer std.testing.allocator.free(std.mem.span(removed));
    defer std.testing.allocator.free(std.mem.span(removed));
    try std.testing.expect(len == 5);
    try std.testing.expect(cloned_len == 5);
    try std.testing.expect(utils.strLen(removed) == 4);
}

// Testing the module containing the function to tokenize
// CLI arguments.
test "Testing the module containing to tokenize CLI arguments" {
    var test_arr: std.ArrayList([*:0]const u8) = std.ArrayList([*:0]const u8)
        .init(std.testing.allocator);
    defer test_arr.deinit();
    const one: [*:0]const u8 = try std.testing.allocator.dupeZ(u8, "build");
    defer std.testing.allocator.free(std.mem.span(one));
    const two: [*:0]const u8 = try std.testing.allocator.dupeZ(u8, "-asdf");
    defer std.testing.allocator.free(std.mem.span(two));
    const three: [*:0]const u8 = try std.testing.allocator.dupeZ(u8, "--local");
    defer std.testing.allocator.free(std.mem.span(three));
    try test_arr.append(one);
    try test_arr.append(two);
    try test_arr.append(three);
    const tokenized: std.ArrayList(lexer.Token) = try lexer.tokenizeArgs(
        std.testing.allocator,
        &test_arr
    );
    defer {
        for (tokenized.items) |item| {
            item.deinit(std.testing.allocator);
        }
        tokenized.deinit();
    }
    try std.testing.expect(tokenized.items.len == 6);
}

// Testing the module containing entities
// to work with set arguments.
test "Testing the module containing entities to work with set arguments." {
    var set_args: std.ArrayList(arg.Argument) = std.ArrayList(arg.Argument)
        .init(std.testing.allocator);
    defer set_args.deinit();
    const one_name: [*:0]const u8 = try std.testing.allocator.dupeZ(u8, "build");
    const one_help: [*:0]const u8 = try std.testing.allocator.dupeZ(u8, "builds something");
    const two_name: [*:0]const u8 = try std.testing.allocator.dupeZ(u8, "verbose");
    const two_help: [*:0]const u8 = try std.testing.allocator.dupeZ(u8, "shows build output");
    const one: arg.Argument = arg.Argument {
        .takes_data = true,
        .name = one_name,
        .help = one_help
    };
    defer one.deinit(std.testing.allocator);
    const two: arg.Argument = arg.Argument {
        .takes_data = false,
        .name = two_name,
        .help = two_help
    };
    defer two.deinit(std.testing.allocator);
    try set_args.append(one);
    try set_args.append(two);
    const is_t: bool = arg.isSet("build", &set_args);
    const ud_t: bool = arg.usesData("build", &set_args);
    const fl_t: [*:0]const u8 = try arg.getArgByLetter(
        'v', 
        std.testing.allocator, 
        &set_args
    );
    defer std.testing.allocator.free(std.mem.span(fl_t));
    try std.testing.expect(is_t == true);
    try std.testing.expect(ud_t == true);
    try std.testing.expect(std.mem.eql(u8, "verbose", std.mem.span(fl_t)));
}

// Testing the module to deserialize tokens.
test "Testing the module to deserialize tokens." {
    var test_arr: std.ArrayList([*:0]const u8) = std.ArrayList([*:0]const u8)
        .init(std.testing.allocator);
    defer test_arr.deinit();
    const i_one: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "build"
    );
    defer std.testing.allocator.free(std.mem.span(i_one));
    const i_two: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "--verbose"
    );
    defer std.testing.allocator.free(std.mem.span(i_two));
    try test_arr.append(i_one);
    try test_arr.append(i_two);
    const tokenized: std.ArrayList(lexer.Token) = try lexer.tokenizeArgs(
        std.testing.allocator,
        &test_arr
    );
    defer {
        for (tokenized.items) |item| {
            item.deinit(std.testing.allocator);
        }
        tokenized.deinit();
    }
    var set_args: std.ArrayList(arg.Argument) = std.ArrayList(arg.Argument)
        .init(std.testing.allocator);
    defer set_args.deinit();
    const one_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "build"
    );
    const one_help: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "builds something"
    );
    const two_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "verbose"
    );
    const two_help: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "shows build output"
    );
    const one: arg.Argument = arg.Argument {
        .takes_data = true,
        .name = one_name,
        .help = one_help
    };
    defer one.deinit(std.testing.allocator);
    const two: arg.Argument = arg.Argument {
        .takes_data = false,
        .name = two_name,
        .help = two_help
    };
    defer two.deinit(std.testing.allocator);
    try set_args.append(one);
    try set_args.append(two);
    const deserialized: std.ArrayList(des.DeserializedArgument) = try des
        .deserializeTokens(
            std.testing.allocator,
            &tokenized,
            &set_args
        );
    defer {
        for (deserialized.items) |item| {
            item.deinit(std.testing.allocator);
        }
        deserialized.deinit();
    }
    try std.testing.expect(deserialized.items.len == 2);    
}

// Testing the module to parse deserialized tokens.
test "Testing the module to parse deserialized tokens." {
    var test_arr: std.ArrayList([*:0]const u8) = std.ArrayList([*:0]const u8)
        .init(std.testing.allocator);
    defer test_arr.deinit();
    const i_one: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "build"
    );
    defer std.testing.allocator.free(std.mem.span(i_one));
    const i_two: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "./local"
    );
    defer std.testing.allocator.free(std.mem.span(i_two));
    const i_three: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "--verbose"
    );
    defer std.testing.allocator.free(std.mem.span(i_three));
    try test_arr.append(i_one);
    try test_arr.append(i_two);
    try test_arr.append(i_three);
    const tokenized: std.ArrayList(lexer.Token) = try lexer.tokenizeArgs(
        std.testing.allocator,
        &test_arr
    );
    defer {
        for (tokenized.items) |item| {
            item.deinit(std.testing.allocator);
        }
        tokenized.deinit();
    }
    var set_args: std.ArrayList(arg.Argument) = std.ArrayList(arg.Argument)
        .init(std.testing.allocator);
    defer set_args.deinit();
    const one_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "build"
    );
    const one_help: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "builds something"
    );
    const two_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "verbose"
    );
    const two_help: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "shows build output"
    );
    const one: arg.Argument = arg.Argument {
        .takes_data = true,
        .name = one_name,
        .help = one_help
    };
    defer one.deinit(std.testing.allocator);
    const two: arg.Argument = arg.Argument {
        .takes_data = false,
        .name = two_name,
        .help = two_help
    };
    defer two.deinit(std.testing.allocator);
    try set_args.append(one);
    try set_args.append(two);
    const deserialized: std.ArrayList(des.DeserializedArgument) = try des
        .deserializeTokens(
            std.testing.allocator,
            &tokenized,
            &set_args
        );

    defer {
        for (deserialized.items) |item| {
            item.deinit(std.testing.allocator);
        }
        deserialized.deinit();
    }  
    const parsed: std.ArrayList(parser.ParsedArgument) = try parser
        .parseDeserialized(
            std.testing.allocator,
            &set_args,
            &deserialized
        );
    defer {
        for (parsed.items) |item| {
            item.deinit(std.testing.allocator);
        }
        parsed.deinit();
    }
    try std.testing.expect(parsed.items.len == 2);
}

// Testing the module that has functions to build the help message.
test "Testing the module that has functions to build the help message." {
    var set_args: std.ArrayList(arg.Argument) = std.ArrayList(arg.Argument)
        .init(std.testing.allocator);
    defer set_args.deinit();
    const one_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "build"
    );
    const one_help: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "builds something"
    );
    const two_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "verbose"
    );
    const two_help: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "shows build output"
    );
    const one: arg.Argument = arg.Argument {
        .takes_data = true,
        .name = one_name,
        .help = one_help
    };
    defer one.deinit(std.testing.allocator);
    const two: arg.Argument = arg.Argument {
        .takes_data = false,
        .name = two_name,
        .help = two_help
    };
    defer two.deinit(std.testing.allocator);
    try set_args.append(one);
    try set_args.append(two);
    const prefix_strings: std.ArrayList([]const u8) = try help.buildLengthStrings(
        std.testing.allocator,
        &set_args
    );
    defer {
        for (prefix_strings.items) |item| {
            std.testing.allocator.free(item);
        }
        prefix_strings.deinit();
    }
    const length: u64 = try help.getLongestPrefix(
        std.testing.allocator,
        &prefix_strings
    );
    const help_message: [*:0]const u8 = try help.buildHelpMessage(
        std.testing.allocator,
        &set_args
    );
    defer std.testing.allocator.free(std.mem.span(help_message));
    try std.testing.expect(prefix_strings.items.len == 2);
    try std.testing.expect(length != 0);
    try std.testing.expect(utils.strLen(help_message) != 0);
}

// Testing the module containing the main "App" structure.
test "Testing the module containing the main \"App\" structure." {
    const app_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "Test App"
    );
    const app_author: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "Alyx Shang"
    );
    const app_version: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "0.1.0"
    );
    var ma: app.App = app.App.init(
        std.testing.allocator,
        app_name,
        app_author,
        app_version
    );
    defer ma.deinit();
    const one_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "greet"
    );
    const one_help: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "greets the user"
    );
    const two_name: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "cgreet"
    );
    const two_help: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "greets the user with their name"
    );
    try ma.setArg(false, one_name, one_help);
    try ma.setArg(true, two_name, two_help);
    var arg_list: std.ArrayList([*:0]const u8) = std.ArrayList([*:0]const u8)
        .init(std.testing.allocator);
    defer {
        for (arg_list.items) |item| {
            std.testing.allocator.free(std.mem.span(item));
        }
        arg_list.deinit();
    }
    const first_arg: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "--cgreet"
    );
    const second_arg: [*:0]const u8 = try std.testing.allocator.dupeZ(
        u8, 
        "Alyx"
    );
    try arg_list.append(first_arg);
    try arg_list.append(second_arg);
    try ma.parseArgs(&arg_list);
    const was_used: bool = ma.argUsed("cgreet");
    const help_msg: [*:0]const u8 = try ma.helpInfo();
    defer std.testing.allocator.free(std.mem.span(help_msg));
    const version_msg: [*:0]const u8 = try ma.versionInfo();
    defer std.testing.allocator.free(std.mem.span(version_msg));
    const arg_data: [*:0]const u8 = try ma.getArgData("cgreet");
    defer std.testing.allocator.free(std.mem.span(arg_data));
    const eqls: bool = std.mem.eql(u8, std.mem.span(arg_data), "Alyx");
    try std.testing.expect(utils.strLen(help_msg) != 0);
    try std.testing.expect(utils.strLen(version_msg) != 0);
    try std.testing.expect(was_used == true);
    try std.testing.expect(eqls == true);
}
