# libloading

A system dynamic library loading primitive, fully inspired by [rust_libloading](https://github.com/nagisa/rust_libloading).

However, this library doesn't prevent dangling-`Symbol`s that may occur after a `Library` is unloaded.
