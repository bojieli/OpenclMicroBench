#include "NetworkStream.clh"

//#define EMULATION

channel NetworkStream tor_in    __attribute__((depth(512)));
channel NetworkStream tor_out   __attribute__((depth(512)));
channel NetworkStream nic_in    __attribute__((depth(512)));
channel NetworkStream nic_out   __attribute__((depth(512)));

channel NetworkStream input_ch  __attribute__((depth(512))); 
channel NetworkStream pkt_ch    __attribute__((depth(512)));
channel NetworkStream meta_ch   __attribute__((depth(512)));

static void dumpFlit(NetworkStream *flit) 
{
  uchar * p = (uchar*)flit;
  for ( int i = 38-1; i >= 0; i-- )
    printf("%02x",p[i]);
  printf("\n");
}

kernel void 
mem_to_channel (global NetworkStream* restrict in, uint flits_per_packet)
{
    NetworkStream flit[64]; // maximum packet size in global memory <= 64 * 32 = 2048 bytes
    uint k = 0;
    
    for (uint i = 0; i < flits_per_packet; i++) {
        flit[i] = in[i];
    }
  
    while(1) {
        write_channel_altera(input_ch, flit[k]); 
        if (k == flits_per_packet - 1) {
            k = 0;
        } else {
            k ++;
        }
    }        
}

kernel void 
header_process (uint ctrl)
{
    bool should_read = 1;
    NetworkStream x;

    while(1) {
        bool success;

        if (should_read) {
            x = read_channel_nb_altera(input_ch, &success);
        }
        
        if (success) {
            if (should_read) {
                should_read = 0; 
                write_channel_altera(pkt_ch, x);
            } else {
                should_read = 1;
                write_channel_altera(meta_ch, x);
            }
        }
    }
}

kernel void 
sender ()
{
    NetworkStream meta, x;
    bool should_read_meta = 1;

    while (1) {
        bool success;

        if (should_read_meta) {
            meta = read_channel_nb_altera(meta_ch, &success);
        } else {
            x = read_channel_nb_altera(pkt_ch, &success);
        }
       
        if (success) {
            if (should_read_meta) {
                should_read_meta = 0;
                // fake opencl compiler to not optimize it out
                write_channel_altera(nic_out, meta);
            } else {
                should_read_meta = 1;
                write_channel_altera(tor_out, x);
            }
        }
    }
}
