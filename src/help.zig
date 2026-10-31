// METZTLI by Alyx Shang.
// Licensed under the FSL v1.

// Importing the "std" namespace.
const std = @import("std");

// Importing the "ArrayList" structure
// from the standard library.
const ArrayList = std.ArrayList;

// Importing the "Allocator" structure
// from the standard library.
const Allocator = std.mem.Allocator;

// Importing the function to create
// a null-terminated formatted string.
const allocPrint = std.fmt.allocPrint;

// Importing the function to get the
// length of a C-String.
const strLen = @import("utils.zig").strLen;

// Importing the structure to encapsulate
// data about an argument that has been set
// in the app.
const Argument = @import("arg.zig").Argument;

// Importing the structure to catch and
// handle errors.
const MetztliErr = @import("err.zig").MetztliErr;

// Importing the function to clone a C-String.
const cloneSlice = @import("utils.zig").cloneSlice;

/// A function to build the prefixes of each help message
/// for each set and accepted argument and append them to
/// an array of strings. If allocation fails or the array cannot
/// be written to, an error is returned.
pub fn buildLengthStrings(
    allocator: Allocator,
    set_args: *ArrayList(Argument)
) !ArrayList([]const u8) {
    var result: ArrayList([]const u8) = .empty;
    errdefer {
        for (result.items) |item| {
            allocator.free(item);
        }
        result.deinit(allocator);
    }
    for (set_args.items) |item| {
        if (item.takes_data) {
            const fmtd: []const u8 = allocPrint(
                allocator,
                "-{c} --{s} {s} DATA",
                .{item.name[0], item.name, item.name}
            ) catch return MetztliErr.AllocErr;
            errdefer allocator.free(fmtd);
            result.append(allocator, fmtd) catch return MetztliErr.WriteErr;
        }
        else {
            const fmtd: []const u8 = allocPrint(
                allocator,
                "-{c} --{s} {s}",
                .{item.name[0], item.name, item.name}
            ) catch return MetztliErr.AllocErr;
            errdefer allocator.free(fmtd);
            result.append(allocator, fmtd) catch return MetztliErr.WriteErr;
        }
    }
    return result;
}

/// A function to get the length of each of the prefixes 
/// of each help message and store each length in an array
/// to get the longest message and return the resulting number
/// as an unsingned integer. If allocation fails or the array 
/// cannot be written to, an error is returned.
pub fn getLongestPrefix(
    allocator: Allocator,
    sub: *const ArrayList([]const u8)
) !u64 {
    var result_nums: ArrayList(u64) = .empty;
    defer result_nums.deinit(allocator);
    for (sub.items) |item| {
        result_nums.append(
            allocator, 
            item.len
        ) catch return MetztliErr.WriteErr;
    }
    const result: u64 = std.mem.max(u64, result_nums.items);
    return result;
}

/// A function to build the help message for an app.
/// If the operation is successful, a pointer to a
/// null-terminated string is returned. If the operation
/// fails, an error is returned.
pub fn buildHelpMessage(
    allocator: Allocator,
    set_args: *ArrayList(Argument)
) ![*:0]const u8 {
    var strings: ArrayList([]const u8) = try buildLengthStrings(
        allocator,
        set_args
    );
    defer {
        for (strings.items) |item| {
            allocator.free(item);
        }
        strings.deinit(allocator);
    } 
    const longest: u64 = try getLongestPrefix(allocator, &strings);
    var slices: ArrayList([]const u8) = .empty; 
    defer {
        for (slices.items) |item| {
            allocator.free(item);
        }
        slices.deinit(allocator);
    }
    for (set_args.items) |item| {
        if (item.takes_data) {
            const fmtd_prefix: []const u8 = allocPrint(
                allocator,
                "-{c} --{s} {s} DATA",
                .{item.name[0], item.name, item.name}
            ) catch return MetztliErr.AllocErr;
            defer allocator.free(fmtd_prefix); 
            errdefer allocator.free(fmtd_prefix); 
            if (fmtd_prefix.len == longest){
                const fmtd: []const u8 = allocPrint(
                    allocator,
                    "{s}  {s}\n",
                    .{fmtd_prefix, item.help}
                ) catch return MetztliErr.AllocErr;
                errdefer allocator.free(fmtd);
                slices.append(allocator,fmtd) catch return MetztliErr.WriteErr;
            }
            else {
                var msg_chars: ArrayList(u8) = .empty;
                defer msg_chars.deinit(allocator);
                msg_chars.appendNTimes(
                    allocator,
                    ' ', 
                    ((longest - fmtd_prefix.len) + 1)
                ) catch return MetztliErr.WriteErr;
                const fmtd: []const u8 = allocPrint(
                    allocator,
                    "{s}{s} {s}\n",
                    .{fmtd_prefix, msg_chars.items, item.help}
                ) catch return MetztliErr.AllocErr;
                errdefer allocator.free(fmtd);
                slices.append(allocator, fmtd) catch return MetztliErr.WriteErr;
            }
        }
        else {
            const fmtd_prefix: []const u8 = allocPrint(
                allocator,
                "-{c} --{s} {s}",
                .{item.name[0], item.name, item.name}
            ) catch return MetztliErr.AllocErr;
            defer allocator.free(fmtd_prefix);
            errdefer allocator.free(fmtd_prefix);
            if (fmtd_prefix.len == longest){
                const fmtd: []const u8 = allocPrint(
                    allocator,
                    "{s}  {s}\n",
                    .{fmtd_prefix, item.help}
                ) catch return MetztliErr.AllocErr;
                errdefer allocator.free(fmtd);
                slices.append(allocator, fmtd) catch return MetztliErr.WriteErr;
            }
            else {
                var msg_chars: ArrayList(u8) = .empty; 
                defer msg_chars.deinit(allocator);
                msg_chars.appendNTimes(
                    allocator,
                    ' ', 
                    ((longest - fmtd_prefix.len) + 1)
                ) catch return MetztliErr.WriteErr;
                const fmtd: []const u8 = allocPrint(
                    allocator,
                    "{s}{s} {s}\n",
                    .{fmtd_prefix, msg_chars.items, item.help}
                ) catch return MetztliErr.AllocErr;
                errdefer allocator.free(fmtd);
                slices.append(allocator, fmtd) catch return MetztliErr.WriteErr;
            }
        }
    }
    const joined = try std.mem.joinZ(allocator, "", slices.items);
    errdefer allocator.free(std.mem.span(joined));
    return joined;
}
