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
const allocPrintZ = std.fmt.allocPrintZ;

// Importing the function to get the
// length of a C-String.
const strLen = @import("utils.zig").strLen;

// Importing the function to remove a character
// from a C-String at the given index.
const removeAt = @import("utils.zig").removeAt;

// Importing the structure to catch and
// handle errors.
const MetztliErr = @import("err.zig").MetztliErr;

// Importing the function to clone a C-String.
const cloneSlice = @import("utils.zig").cloneSlice;

// An enumeration that lists
// all possible argument types.
pub const TokenType = enum(u8) {
    Entity,
    MinusArg,
    MinusMinusArg
};

// A structure to encapsulate
// data about a token captured
// from an argument stream.
pub const Token = struct {
    value: [*:0]const u8,
    token_type: TokenType,
    pub fn deinit(
        self: *const Token,
        allocator: Allocator
    ) void {
        allocator.free(std.mem.span(self.value));
    }
};

/// A function to tokenize a stream of 
/// arguments and return this stream as
/// an instance of the `ArrayList` structure
/// containing instances of the `Token`
/// structure. If allocation fails or the
/// stream cannot be appended to, an error
/// is returned.
pub fn tokenizeArgs(
    allocator: Allocator,
    args: *ArrayList([*:0]const u8)
) !ArrayList(Token) {
    if (args.items.len == 0){
        return MetztliErr.EmptyArgs;
    }
    else {
        var result: ArrayList(Token) = ArrayList(Token)
            .init(allocator);
        errdefer {
            for (result.items) |item| {
                item.deinit(allocator);
            }
            result.deinit();
        }
        for (args.items) |arg| { 
            if (arg[0] == '-'){
                if (arg[1] == '-'){
                    const one_minus: [*:0]const u8 = try removeAt(0,arg,allocator);
                    defer allocator.free(std.mem.span(one_minus));
                    errdefer allocator.free(std.mem.span(one_minus));
                    const no_minus: [*:0]const u8 = try removeAt(0,one_minus,allocator);
                    errdefer allocator.free(std.mem.span(no_minus));
                    const token: Token = Token {
                        .value = no_minus,
                        .token_type = .MinusMinusArg
                    };
                    result.append(token)
                        catch return MetztliErr.WriteErr;
                }
                else {
                    const no_minus: [*:0]const u8 = try removeAt(0,arg,allocator);
                    defer allocator.free(std.mem.span(no_minus));
                    errdefer allocator.free(std.mem.span(no_minus));
                    var cursor: u64 = 0;
                    const no_minus_len: u64 = strLen(no_minus);
                    var arg_arr: ArrayList(u8) = ArrayList(u8)
                        .init(allocator);
                    errdefer arg_arr.deinit();
                    while (cursor < no_minus_len){
                        const fmtd: [*:0]const u8 = allocPrintZ(
                            allocator,
                            "{c}",
                            .{no_minus[cursor]}
                        ) catch return MetztliErr.AllocErr;
                        errdefer allocator.free(std.mem.span(fmtd));
                        const token: Token = Token {
                            .value = fmtd,
                            .token_type = .MinusArg
                        };
                        result.append(token)
                            catch return MetztliErr.WriteErr;
                        cursor = cursor + 1;
                    }
                }
            }
            else {
                const cloned: [*:0]const u8 = try cloneSlice(arg,allocator);
                errdefer allocator.free(std.mem.span(cloned));
                const token: Token = Token {
                    .value = cloned,
                    .token_type = .Entity
                };
                result.append(token)
                    catch return MetztliErr.WriteErr;
            }
        }
        return result;
    }
}
