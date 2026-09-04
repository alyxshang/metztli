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

// Importing the structure to catch and
// handle errors.
const MetztliErr = @import("err.zig").MetztliErr;

// Importing the function to clone a C-String.
const cloneSlice = @import("utils.zig").cloneSlice;

/// A structure to encapsulate data
/// about an argument set by the user.
pub const Argument = struct {
    takes_data: bool,
    name: [*:0]const u8,
    help: [*:0]const u8,

    /// A function to attempt to
    /// create a clone of the current
    /// instance and return this instance.
    /// If allocation fails, an error is
    /// returned.
    pub fn clone(
        self: *const Argument,
        allocator: Allocator
    ) !Argument {
        const c_name: [*:0]const u8 = allocator.dupeZ(
            u8,
            std.mem.span(self.name),
        ) catch return MetztliErr.AllocErr;
        const c_help: [*:0]const u8 = allocator.dupeZ(
            u8,
            std.mem.span(self.help),
        ) catch return MetztliErr.AllocErr;
        return Argument {
            .takes_data = self.takes_data,
            .name = c_name,
            .help = c_help
        };
    }

    /// A function to drop
    /// all heap-allocated
    /// resources of this
    /// structure.
    pub fn deinit(
        self: *const Argument,
        allocator: Allocator
    ) void {
        allocator.free(std.mem.span(self.name));
        allocator.free(std.mem.span(self.help));
    }
};

/// A function to check whether
/// an argument has been set or not,
/// given the argument's name.
/// A boolean is returned to reflect
/// this.
pub fn isSet(
    arg: [*:0]const u8,
    args: *ArrayList(Argument)
) bool {
    var result: bool = false;
    for (args.items) |*l_arg| {
        const eqls: bool = std.mem.eql(
            u8,
            std.mem.span(l_arg.name),
            std.mem.span(arg)
        );
        if (eqls){
            result = true;
        }
    }
    return result;
}

/// A function to check whether
/// an argument has been set and
/// accepts data from the user.
/// A boolean is returned to reflect
/// this.
pub fn usesData(
    arg: [*:0]const u8,
    args: *ArrayList(Argument)
) bool {
    var result: bool = false;
    for (args.items) |*l_arg| {
        const eqls: bool = std.mem.eql(
            u8,
            std.mem.span(l_arg.name),
            std.mem.span(arg)
        );
        if (eqls and l_arg.takes_data){
            result = true;
        }
    }
    return result;
}

/// A function to retrieve
/// the name of an argument
/// from the list of arguments
/// given the argument's first
/// letter. If allocation fails
/// or the argument cannot be found
/// an error is returned.
pub fn getArgByLetter(
    sub: u8,
    allocator: Allocator,
    set_args: *ArrayList(Argument)
) ![*:0]const u8 {
    for (set_args.items) |arg| {
        if (arg.name[0] == sub){
            return (try cloneSlice(arg.name, allocator));
        }
    }
    return MetztliErr.ArgNotFound;
}
