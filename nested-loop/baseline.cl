#include "NetworkStream.clh"

//#define EMULATION

channel NetworkStream tor_in    __attribute__((depth(512)));
channel NetworkStream tor_out   __attribute__((depth(512)));
channel NetworkStream nic_in    __attribute__((depth(512)));
channel NetworkStream nic_out   __attribute__((depth(512)));

kernel void 
mem_to_channel (global NetworkStream* restrict in, uint flits_per_packet)
{
    NetworkStream flit[64]; // maximum packet size in global memory <= 64 * 32 = 2048 bytes

    if (flits_per_packet != 2)
        return;
    
    flit[0] = in[0];
    flit[1] = in[1];
  
    while(1) {
        #pragma unroll 2
        for (uint i=0; i<2; i++) {
            write_channel_altera(tor_out, flit[i]);
        }
    }        
}
