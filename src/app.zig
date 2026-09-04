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

// Importing the structure encapsulating
// data about a token captured from a stream
// of arguments.
const Token = @import("lexer.zig").Token;

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

// Importing the function to tokenize
// arguments.
const tokenizeArgs = @import("lexer.zig").tokenizeArgs;

// Importing the structure to encapsulate
// data about a parsed argument.
const ParsedArgument = @import("parser.zig").ParsedArgument;

// Importing the function to build a help message from
// the set arguments.
const buildHelpMessage = @import("help.zig").buildHelpMessage;

// Importing the function to deserialize 
// tokenized arguments.
const deserializeTokens = @import("des.zig").deserializeTokens;

// Importing the function to parse deserialized arguments.
const parseDeserialized = @import("parser.zig").parseDeserialized;

// Importing the data structure that encapsulates
// data about an argument deserialized from a token.
const DeserializedArgument = @import("des.zig").DeserializedArgument;

/// A data structure to encapsulate
/// data about a Zig CLI app.
pub const App = struct {
    name: [*:0]const u8,
    allocator: Allocator,
    author: [*:0]const u8,
    version: [*:0]const u8,
    arguments: ArrayList(Argument),
    parsed_arguments: ArrayList(ParsedArgument),

    /// A function to create a new
    /// instance of the `App` structure
    /// and return it.
    pub fn init(
        allocator: Allocator,
        name: [*:0]const u8,
        author: [*:0]const u8,
        version: [*:0]const u8
    ) App {
        const args: ArrayList(Argument) = ArrayList(Argument)
            .init(allocator);
        const parsed_args: ArrayList(ParsedArgument) = ArrayList(ParsedArgument)
            .init(allocator);

        return App {
            .name = name,
            .author = author,
            .arguments = args,
            .version = version,
            .allocator = allocator,
            .parsed_arguments = parsed_args
        };
    }

    /// A function to set an argument and append
    /// it to the internal store of accepted
    /// arguments. If this operation fails,
    /// an error is returned.
    pub fn setArg(
        self: *App,
        takes_data: bool,
        name: [*:0]const u8,
        help: [*:0]const u8
    ) !void {
        const added: Argument = Argument {
            .name = name,
            .help = help,
            .takes_data = takes_data
        };
        self.arguments.append(added)
            catch return MetztliErr.WriteErr;
    }

    /// A function to parse
    /// a stream of "cleaned"
    /// arguments and populate
    /// the internal array of arguments.
    pub fn parseArgs(
        self: *App,
        recvd: *ArrayList([*:0]const u8),
    ) !void {
        var tokenized: ArrayList(Token) = try tokenizeArgs(
            self.allocator, 
            recvd
        ); 
        defer {
            for (tokenized.items) |item| {
                item.deinit(self.allocator);
            }
            tokenized.deinit();
        } 
        var deserialized: ArrayList(DeserializedArgument) = try deserializeTokens(
            self.allocator,
            &tokenized,
            &self.arguments
        );
        defer {
            for (deserialized.items) |item| {
                item.deinit(self.allocator);
            }
            deserialized.deinit();
        }
        const parsed: ArrayList(ParsedArgument) = try parseDeserialized(
            self.allocator,
            &self.arguments,
            &deserialized
        ); 
        self.parsed_arguments = parsed;
    }

    /// A function to check whether
    /// an argument has been used.
    /// A boolean is returned to reflect
    /// this.
    pub fn argUsed(
        self: *App,
        arg: [*:0]const u8,
    ) bool {
        var result: bool = false;
        for (self.parsed_arguments.items) |pa| {
            const eqls: bool = std.mem.eql(
                u8,
                std.mem.span(pa.name),
                std.mem.span(arg)
            );
            if (eqls){
                result = true;
            }
        }
        return result;
    }

    /// A function to check whether
    /// an argument has been used.
    /// A boolean is returned to reflect
    /// this.
    pub fn getArgData(
        self: *App,
        arg: [*:0]const u8,
    ) ![*:0]const u8 {
        for (self.parsed_arguments.items) |pa| {
            const eqls: bool = std.mem.eql(
                u8,
                std.mem.span(pa.name),
                std.mem.span(arg)
            );
            if (eqls) {
                if (pa.data) |data| {
                    const cloned: [*:0]const u8 = try cloneSlice(
                        data,
                        self.allocator
                    );
                    errdefer self.allocator.free(std.mem.span(cloned));
                    return cloned;
                }
                else { 
                    return MetztliErr.NoDataSupplied;
                }
            }
        }
        return MetztliErr.ArgNotFound;
    }

    /// A function that attempts
    /// to return version info
    /// on the current app.
    /// If allocation fails, an 
    /// error is returned.
    pub fn versionInfo(
        self: *App
    ) ![*:0]const u8 {
        const msg: [*:0]const u8 = allocPrintZ(
            self.allocator,
            "{s} v.{s}\nby {s}\n",
            .{self.name, self.version, self.author}
        ) catch return MetztliErr.AllocErr;
        errdefer self.allocator.free(std.mem.span(msg));
        return msg;
    }

    /// A function that attempts
    /// to return help info on the
    /// currently set arguments.
    /// If allocation fails, an 
    /// error is returned.
    pub fn helpInfo(
        self: *App
    ) ![*:0]const u8 {
        const help: [*:0]const u8 = try buildHelpMessage(
            self.allocator,
            &self.arguments
        );
        errdefer self.allocator.free(std.mem.span(help));
        return help;
    }

    /// A function to drop all 
    /// heap-allocated resources
    /// this structure holds.
    pub fn deinit(
        self: *App
    ) void {
        self.allocator.free(std.mem.span(self.name)); 
        self.allocator.free(std.mem.span(self.author));
        self.allocator.free(std.mem.span(self.version));
        for (self.arguments.items) |arg| {
            arg.deinit(self.allocator);
        }
        self.arguments.deinit();
        for (self.parsed_arguments.items) |arg| {
            arg.deinit(self.allocator);
        }
        self.parsed_arguments.deinit();
    }
};
