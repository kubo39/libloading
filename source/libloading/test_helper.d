module test_helper;

extern (C):

__gshared static uint TEST_STATIC_UINT = 0;

__gshared static void* TEST_STATIC_PTR;

uint test_identity_uint(uint x)
{
    return x;
}
