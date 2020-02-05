import libloading;

version (linux) enum libm = "libm-2.27.so";
else version (OSX) enum libm = "libm.dylib";
else version (Posix) enum libm = "libm.so";
else static assert(false);

alias ceilFunc = double function(double);

void main()
{
    auto lib = loadLibrary(libm);
    auto ceil = lib.getSymbol!(ceilFunc)("ceil");
    assert(ceil(0.45) == 1);
}
