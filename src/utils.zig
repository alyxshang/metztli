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

/// A function to get the 
/// length of a string that
/// is a pointer to a 
/// null-terminated
/// slice.
pub fn strLen(
    sub: [*:0]const u8
) u64 {
    var result: u64 = 0;
    while (sub[result] != 0){
        result = result + 1;
    }
    return result;
}

/// A function to clone
/// a pointer to a null-terminated
/// string slice. If allocation fails
/// an error is returned. If not, the
/// pointer to the slice is returned.
pub fn cloneSlice(
    sub: [*:0]const u8,
    allocator: Allocator
) ![*:0]const u8 {
    var cursor: u64 = 0;
    var chars: ArrayList(u8) = ArrayList(u8)
        .init(allocator);
    errdefer chars.deinit();
    while (sub[cursor] != 0){
        chars.append(sub[cursor])
            catch return MetztliErr.WriteErr;
        cursor = cursor + 1;
    }
    const joined: [*:0]const u8 = chars.toOwnedSliceSentinel(0)
        catch return MetztliErr.AllocErr;
    errdefer allocator.free(std.mem.span(joined));
    return joined;
}

/// A function to remove a character
/// from a null-terminated string pointed
/// to by a pointer. If allocation fails,
/// an error is returned. In any other case
/// a pointer to a null-terminated string
/// with the character removed is returned.
pub fn removeAt(
    at: u64,
    sub: [*:0]const u8,
    allocator: Allocator
) ![*:0]const u8 {
    var cursor: u64 = 0;
    const len: u64 = strLen(sub);
    var result: ArrayList(u8) = ArrayList(u8)
        .init(allocator);
    errdefer result.deinit();
    while (cursor < len) {
        if (cursor != at){
            result.append(sub[cursor])
                catch return MetztliErr.WriteErr;
        }
        cursor = cursor + 1;
    }
    const joined: [*:0]const u8 = result.toOwnedSliceSentinel(0)
        catch return MetztliErr.AllocErr;
    errdefer allocator.free(std.mem.span(joined));
    return joined;
}
