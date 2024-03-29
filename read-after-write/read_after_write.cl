typedef ulong8 NetworkStream;

channel NetworkStream tor_out   __attribute__((depth(512)));

kernel void 
mem_to_channel (global NetworkStream* restrict in, uint flits_per_packet)
{
    NetworkStream flit[64];
    uint k = 0;
    
    for (uint i = 0; i < flits_per_packet; i++) {
        flit[i] = in[i];
    }
  
    while(1) {
        write_channel_altera(tor_out, flit[k]); 
        k ++;
        if (k == flits_per_packet) {
            k = 0;
        }
    }        
}
