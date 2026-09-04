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

// Importing the structure to encapsulate
// data about an argument that has been set
// in the app.
const Argument = @import("arg.zig").Argument;

// Importing the function to check whether
// an argument has been set and accepts
// user data, given its name.
const usesData = @import("arg.zig").usesData;

// Importing the structure to catch and
// handle errors.
const MetztliErr = @import("err.zig").MetztliErr;

// Importing the function to clone a C-String.
const cloneSlice = @import("utils.zig").cloneSlice;

// Importing the data structure that encapsulates
// data about an argument deserialized from a token.
const DeserializedArgument = @import("des.zig").DeserializedArgument;

/// A data structure encapsulating data
/// about an argument parsed from a deserialized
/// argument. If the argument has been set and
/// accepts data, the data field is populated with
/// a C-String.
pub const ParsedArgument = struct {
    name: [*:0]const u8,
    data: ?[*:0]const u8,

    /// A function to drop all heap-allocated
    /// resources of this structure.
    pub fn deinit(
        self: *const ParsedArgument,
        allocator: Allocator
    ) void {
        if (self.data) |data| {
            allocator.free(std.mem.span(data));
        }
        allocator.free(std.mem.span(self.name));
    }
};

/// A function to parse entities in a stream
/// of deserialized arguments into a stream of
/// parsed arguments. If the operation is successful,
/// an instance of the `ArrayList` structure is returned
/// containing instances of the `ParsedArgument` structure.
/// If allocation fails, the stream cannot be written to or
/// an argument combination is erroneous, an error is returned.
pub fn parseDeserialized(
    allocator: Allocator,
    set_args: *ArrayList(Argument),
    sub: *const ArrayList(DeserializedArgument)
) !ArrayList(ParsedArgument) {
    var cursor: u64 = 0;
    var result: ArrayList(ParsedArgument) = ArrayList(ParsedArgument)
        .init(allocator);
    errdefer {
        for (result.items) |item| {
            item.deinit(allocator);
        }
        result.deinit();
    }
    while (cursor < sub.items.len) {
        const current: DeserializedArgument = sub.items[cursor];
        if (current.is_arg){
            if (usesData(current.entity, set_args)){
                if ((cursor + 1) < sub.items.len and 
                    sub.items[cursor + 1].is_arg == false)
                {
                    const next: DeserializedArgument = sub.items[cursor + 1];
                    const cloned: [*:0]const u8 = try cloneSlice(
                        current.entity, 
                        allocator
                    );
                    errdefer allocator.free(std.mem.span(cloned));
                    const cloned_data: [*:0]const u8 = try cloneSlice(
                        next.entity, 
                        allocator
                    );
                    errdefer allocator.free(std.mem.span(cloned_data));
                    const parsed: ParsedArgument = ParsedArgument{
                        .name = cloned,
                        .data = cloned_data
                    };
                    result.append(parsed) catch return MetztliErr.WriteErr;
                    cursor = cursor + 2;
                }
                else {
                    return MetztliErr.NoDataSupplied;                    
                }
            }
            else {
                const cloned: [*:0]const u8 = try cloneSlice(current.entity, allocator);
                errdefer allocator.free(std.mem.span(cloned));
                const parsed: ParsedArgument = ParsedArgument{
                    .name = cloned,
                    .data = null
                };
                result.append(parsed) catch return MetztliErr.WriteErr;
                cursor = cursor + 1;
            }
        }
        else {
            return MetztliErr.UnknownArg;
        }
    }
    return result;
}
