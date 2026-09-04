// METZTLI by Alyx Shang.
// Licensed under the FSL v1.

// Exporting the module containing
// the structure to catch and handle
// errors.
pub const err = @import("err.zig");

/// Exporting the module containing
/// entities to handle arguments set
/// by a user.
pub const arg = @import("arg.zig");

/// Exporting the module containing
/// entities to deserialize tokenized
/// arguments.
pub const des = @import("des.zig");

/// Exporting the module containing
/// the main `App` structure.
pub const app = @import("app.zig");

/// Exporting the module containing
/// the functions to generate a help
/// message for arguments set by the
/// user.
pub const help = @import("help.zig");

/// Exporting the module containing
/// the functions to tokenize received
/// CLI arguments.
pub const lexer = @import("lexer.zig");

/// Exporting the module containing
/// utility functions.
pub const utils = @import("utils.zig");

/// Exporting the module containing
/// the functions to parse received
/// CLI arguments.
pub const parser = @import("parser.zig");
