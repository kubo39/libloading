module libloading;

public import libloading.library;

version(unittest)
{
    version (Posix) enum extension = ".so";
    else version (Windows) enum extension = ".dll";

    enum LIBRARY_NAME = "tests/libtest_helper" ~ extension;
}

unittest
{
    auto lib = loadLibrary(LIBRARY_NAME);
    auto f = lib.getSymbol!(uint function(uint))("test_identity_uint");
    assert(42 == f(42));
}

unittest
{
    auto lib = loadLibrary(LIBRARY_NAME);
    auto var = lib.getSymbol!(uint*)("TEST_STATIC_UINT");
    *var = 42;
    auto var2 = lib.getSymbol!(uint*)("TEST_STATIC_UINT");
    assert(*var2 == 42);
}

version(unittest)
shared static this()
{
    import std.process;

    auto dc = environment.get("DC", "dmd");
    // 'betterC' is a hack to supress 'DSO being registered ..' error.
    auto result = execute([dc, "-shared", "-betterC", "-of=" ~ LIBRARY_NAME,
                           "source/libloading/test_helper.d"]);
    assert(result.status == 0);
}

version(unittest)
shared static ~this()
{
    import std.file;
    remove(LIBRARY_NAME);
}
