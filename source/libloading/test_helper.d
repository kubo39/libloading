module test_helper;

extern (C):

__gshared static uint TEST_STATIC_UINT = 0;

uint test_identity_uint(uint x)
{
    return x;
}
