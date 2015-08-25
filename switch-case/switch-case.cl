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

        bool key_equal1 = (x == key1[hash]);
        bool empty1 = (key1[hash] == 0);
        bool key_equal2 = (x == key2[hash]);
        bool empty2 = (key2[hash] == 0);

        switch (key_equal1 | (key_equal2 << 1)
            | (empty1 << 2) | (empty2 << 3))
        {
            // no match, no empty slots
            case 0: 
            dropped_counter ++;
            break;

            // match slot 1
            case 1:
            case 3:
            case 5:
            case 7:
            case 9:
            case 11:
            case 13:
            case 15:
            counter1[hash] ++;
            break;

            // not match slot 1, match slot 2
            case 2:
            case 6:
            case 10:
            case 14:
            counter2[hash] ++;
            break;

            // no match, slot 1 empty 
            case 4:
            case 12:
            key1[hash] = x;
            counter1[hash] = 1;
            break;

            // no match, slot 1 not empty, slot 2 empty
            case 8:
            key2[hash] = x;
            counter2[hash] = 1;
            break;
        }
    }
}
