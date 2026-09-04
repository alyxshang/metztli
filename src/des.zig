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

// Importing the function to check whether
// an argument has been set, given its name.
const isSet = @import("arg.zig").isSet;

// Importing the structure encapsulating
// data about a token captured from a stream
// of arguments.
const Token = @import("lexer.zig").Token;

// Importing the structure to encapsulate
// data about an argument that has been set
// in the app.
const Argument = @import("arg.zig").Argument;

// Importing the structure to catch and
// handle errors.
const MetztliErr = @import("err.zig").MetztliErr;

// Importing the function to clone a C-String.
const cloneSlice = @import("utils.zig").cloneSlice;

// Importing the function to retrieve the name of
// a set argument given the argument's first letter.
const getArgByLetter = @import("arg.zig").getArgByLetter;

/// A data structure that encapsulates data
/// about a deserialized argument. This data
/// is taken from a token.
pub const DeserializedArgument = struct {
    entity: [*:0]const u8,
    is_arg: bool,
    pub fn deinit(
        self: *const DeserializedArgument,
        allocator: Allocator
    ) void {
        allocator.free(std.mem.span(self.entity));
    }
};

/// A function to deserialize a stream
/// of tokens taken from a stream CLI
/// arguments.  Each token is checked
/// to see if it is a set argument or not.
/// This data is recorded in an instance of
/// the `DeserializedArgument` structure and
/// appended to an instance of the `ArrayList`
/// structure. If allocations fail or writing to
/// the stream, an error is returned.
pub fn deserializeTokens(
    allocator: Allocator,
    sub: *const ArrayList(Token),
    set_args: *ArrayList(Argument)
) !ArrayList(DeserializedArgument) {
    var result: ArrayList(DeserializedArgument) = ArrayList(DeserializedArgument)
        .init(allocator);
    errdefer {
        for (result.items) |*item| {
            item.deinit(allocator);
        }
        result.deinit();
    }
    for (sub.items) |item| {
        var is_arg: bool = false;
        var payload: ?[*:0]const u8 = null;
        switch (item.token_type){
            .Entity => { 
                if (isSet(item.value, set_args)){
                    is_arg = true;
                }
                const cloned: [*:0]const u8 = try cloneSlice(item.value, allocator);
                errdefer allocator.free(std.mem.span(cloned));
                payload = cloned;
            },
            .MinusArg => {
                const name: [*:0]const u8 = try getArgByLetter(item.value[0], allocator, set_args);
                if (isSet(name, set_args)){
                    is_arg = true;
                    payload = name;
                }
                else {
                    return MetztliErr.ArgNotRecognized;
                }
            },
            .MinusMinusArg => {
                if (isSet(item.value, set_args)){
                    is_arg = true;
                    const cloned: [*:0]const u8 = try cloneSlice(item.value, allocator);
                    errdefer allocator.free(std.mem.span(cloned));
                    payload = cloned;
                }
                else {
                    return MetztliErr.ArgNotRecognized;
                }

            }
        }
        if (payload) |p| {
            const da: DeserializedArgument = DeserializedArgument {
                .is_arg = is_arg,
                .entity = p
            };
            result.append(da) catch {
                allocator.free(std.mem.span(p));
                return MetztliErr.WriteErr;
            };
        }
        else {
            return MetztliErr.ValueNotRecorded;
        }
    }
    return result;
}
