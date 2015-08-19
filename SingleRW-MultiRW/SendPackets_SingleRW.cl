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
    NetworkStream x;
    bool should_write_meta = 0;

    while(1) {
        if (should_write_meta) {
            // write fake metadata to metadata channel
            write_channel_altera(meta_ch, x);
            should_write_meta = 0;
        } 
        else {
            pNetworkStream pFlit;

            x = read_channel_altera(input_ch);
            pFlit = (pNetworkStream) &x;
            
            if (pFlit->sop) { // the first flit of each packet
                should_write_meta = 1; // write meta next iteration
            }

            // write the flit "as is" to packet channel
            write_channel_altera(pkt_ch, x);
        }
    }
}

kernel void 
sender ()
{
    bool should_read_meta = 1;
    uint flit_count = 0;

    while (1) {
        NetworkStream meta, x;

        if (should_read_meta) {
            meta = read_channel_altera(meta_ch);
            should_read_meta = 0;
        }
        else {
            pNetworkStream pFlit;

            x = read_channel_altera(pkt_ch);
            pFlit = (pNetworkStream) &x;

            if (pFlit->eop) { // the last flit of the packet
                should_read_meta = 1; // read meta of next packet next iteration
                flit_count = 0;
            } else {
                flit_count ++;
            }

            // send the flit to TOR_OUT
            write_channel_altera(tor_out, x);
        }
    }
}
