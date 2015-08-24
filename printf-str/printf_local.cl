kernel void
test_printf (global char * restrict buf)
{
    unsigned char local_buf[20];
    for (uint i=0; i<20; i++)
        local_buf[i] = buf[i];

    printf ("local hex : ");
    for (uint i=0; i<20; i++)
        printf ("%02x ", local_buf[i]);
    printf ("\n");

    printf ("local str : %s\n", local_buf);
}
