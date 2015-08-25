typedef union {
    ulong2 raw;

    struct {
        uchar arr[100];
        uchar index;
    } s;
} mystruct;

kernel void
test_struct () {
    mystruct s;

    s.s.index = 0;
    while (s.s.index < 100) {
        s.s.arr[s.s.index++] = 0;
    }
}
