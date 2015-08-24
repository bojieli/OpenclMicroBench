kernel void
test_printf (global char * restrict buf)
{
    printf ("global hex : ");
    for (uint i=0; i<20; i++)
        printf ("%02x ", buf[i]);
    printf ("\n");

    printf ("global str : %s\n", buf);
}
