typedef struct {
    uchar  c1;
    ulong  l1;
} NetworkStream;

kernel void
test_struct ()
{
    printf("Before struct variable definition\n");
    NetworkStream s;
    printf("After struct variable definition\n");
}
