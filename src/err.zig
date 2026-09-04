// METZTLI by Alyx Shang.
// Licensed under the FSL v1.

/// A data structure to catch
/// and handle errors in this
/// library.
pub const MetztliErr = error { 
    AllocErr,
    WriteErr,
    EmptyArgs,
    UnknownArg,
    ArgNotFound,
    NoDataSupplied,
    ValueNotRecorded,
    ArgNotRecognized,
};
