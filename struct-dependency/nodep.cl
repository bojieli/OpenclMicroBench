kernel void
test_struct () {
    uchar arr[100];
    uchar index;

    index = 0;
    while (index < 100) {
        arr[index++] = 0;
    }
}
