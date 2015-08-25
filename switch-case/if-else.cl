channel ulong input_ch __attribute__((depth(512)));

kernel void
test_branch ()
{
    ulong key1[256], key2[256];
    ulong counter1[256], counter2[256];
    ulong dropped_counter = 0;

    while (1) {
        ulong x = read_channel_altera(input_ch);
        uchar *raw = (uchar *) &x;
        uchar hash = raw[0] ^ raw[1] ^ raw[2] ^ raw[3] ^ raw[4] ^ raw[5] ^ raw[6] ^ raw[7];

        if (x == key1[hash]) {
            counter1[hash] ++;
        }
        else if (x == key2[hash]) {
            counter2[hash] ++;
        }
        else if (key1[hash] == 0) {
            key1[hash] = x;
            counter1[hash] = 1;
        }
        else if (key2[hash] == 0) {
            key2[hash] = x;
            counter2[hash] = 1;
        }
        else {
            dropped_counter ++;
        }
    }
}
