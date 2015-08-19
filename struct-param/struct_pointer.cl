typedef ulong8 NetworkStream;
typedef struct __attribute((packed)) {
    bool valid;
    unsigned char data[sizeof(ulong8) - sizeof(bool)];
} *pNetworkStream;

channel NetworkStream tor_out   __attribute__((depth(512)));

kernel void 
sender (global NetworkStream* restrict in, uint flits_per_packet)
{
    printf("Enter kernel\n");
    NetworkStream flit[64];
    printf("Flit is defined\n");
    for (uint i = 0; i < flits_per_packet; i++) {
        flit[i] = in[i];
        pNetworkStream pFlit = (pNetworkStream) &flit[i];
        printf("%d\n", pFlit->valid);
    }
    printf("Flit is copied\n");

    while(1) {
        for (uint i = 0; i < flits_per_packet; i++)
            write_channel_altera(tor_out, flit[i]);
    }
}
