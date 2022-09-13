module libloading.library;

private:

version (Windows)
{
    import core.runtime;
}
else version (Posix)
{
    import core.sys.posix.dlfcn;
}
else static assert(false, "Unsupported platform.");

import std.exception : enforce, errnoEnforce;
import std.traits : isFunctionPointer, isPointer;

/**
 * Whole error handling scheme in libdl is done via setting and querying some
 * global state.
 */
version(Posix)
bool withDlerror(bool delegate() @nogc nothrow del, string* message)
    /+ @nogc +/ nothrow
{
    /**
     * NOTE: there are some platforms that is still MT-unsafe, like FreeBSD/NetBSD/DragonflyBSD.
     */
    import core.stdc.string : strlen;

    immutable result = del();
    if (!result)
    {
        auto error = dlerror();
        if (error is null)
            return false;
        // copy the error string above, when we call dlerror again to let libdl
        // know it may free its copy of the string.
        *message = error[0 .. strlen(error)].idup;
    }
    return result;
}

public:

/// Library.
struct Library
{
    const(void)* handle;
    alias handle this;
}

/// Find and load a library.
Library loadLibrary(const(char)* filename = null, int flags = RTLD_NOW)
{
    Library library;

    version (Windows)
    {
        library = Runtime.loadLibrary(filename);
    }
    else version (Posix)
    {
        string errorMessage;
        bool result = withDlerror(delegate() @nogc nothrow {
                const result = dlopen(filename, flags);
                if (result is null)
                    return false;
                library = result;
                return true;
            }, &errorMessage);

        if (!result)
        {
            if (errorMessage is null)
                enforce(false, "Unknwon reason");
            errnoEnforce(false, errorMessage);
        }
    }

    return library;
}

/// Ditto.
Library loadLibrary(string filename, int flags = RTLD_NOW)
{
    import std.string : toStringz;
    return loadLibrary(filename.toStringz, flags);
}

/// Dispose a loaded library.
void unload(ref Library library) nothrow
{
    version (Windows)
    {
        Runtime.unloadLibrary(library);
    }
    version (Posix)
    {
        string errorMessage;
        withDlerror(delegate() @nogc nothrow {
                return dlclose(cast(void*) library) == 0;
            }, &errorMessage);
    }
}

/// Symbol from a library.
struct Symbol(T)
{
    T pointer;
    alias pointer this;

    version(linux)
    string toString()
    {
        import core.sys.linux.dlfcn : Dl_info, dladdr;
        import std.format : format;
        import std.string : fromStringz;

        Dl_info info = void;
        if (dladdr(this.pointer, &info) != 0)
        {
            if (info.dli_sname is null)
                return format!"Unknown symbol from %s"(info.dli_fname.fromStringz);
            else
                return format!"Symbol %s from %s"(
                    info.dli_sname.fromStringz,
                    info.dli_fname.fromStringz);
        }
        else return "Unknown symbol";
    }
}

/// Get a pointer to function by symbol name.
Symbol!T getSymbol(T)(ref Library library, const(char)* symbolName)
    if (isFunctionPointer!T || isPointer!T)
{
    Symbol!T symbol;

    version (Windows)
    {
        import core.sys.windows.windows : GetProcAddress;
        import std.format : format;

        const p = GetProcAddress(library, symbolName);
        if (p is null)
            enforce(false, format!"Could not load function function '%s'"(symbolName));
        symbol = cast(T) p;
    }
    else version (Posix)
    {
        string errorMessage;
        bool result = withDlerror(delegate() @nogc nothrow {
                // clear any existing error, please see `man dlsym`.
                dlerror();
                const p = dlsym(cast(void*)library, symbolName);
                if (p is null)
                    return false;
                symbol = cast(T) p;
                return true;
            }, &errorMessage);

        if (!result)
        {
            if (errorMessage is null)
                enforce(false, "Unknwon reason");
            errnoEnforce(false, errorMessage);
        }
    }

    return symbol;
}

/// Ditto.
Symbol!T getSymbol(T)(ref Library library, string symbolName)
    if (isFunctionPointer!T || isPointer!T)
{
    import std.string : toStringz;
    return getSymbol!T(library, symbolName.toStringz);
}
