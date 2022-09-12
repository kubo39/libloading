# libloading

A system dynamic library loading primitive, fully inspired by [rust_libloading](https://github.com/nagisa/rust_libloading). However, this library doesn't prevent dangling-`Symbol`s that may occur after a `Library` is unloaded.

Using this library allows loading dynamic libraries as well as use functions and static variables these libraries contain.

## Example

```d
alias ceilFunc = double function(double);

// Load a shared library.
auto lib = loadLibrary(DYNAMIC_LIBRARY_NAME);

// Get a function pointer by symbol name.
auto ceil = lib.getSymbol!(ceilFunc)("ceil");
assert(ceil(0.45) == 1);

lib.unload();
```
