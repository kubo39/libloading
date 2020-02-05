import libloading;

version (linux) enum libm = "libm.so.6";
else version (OSX) enum libm = "libm.dylib";
else version (Posix) enum libm = "libm.so";
else static assert(false);

alias ceilFunc = double function(double) @nogc nothrow;

void main()
{
    auto lib = loadLibrary(libm);
    auto ceil = lib.getSymbol!(ceilFunc)("ceil");
    assert(ceil(0.45) == 1);

    version (CRuntime_Glibc)
    {
        import std.stdio;
        writeln(ceil);
    }
}
