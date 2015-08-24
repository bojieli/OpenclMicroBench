channel ulong event_uplink __attribute__((depth(1))); 
channel ulong event_ch __attribute__((depth(1))); 

kernel void
worker ()
{
    // main loop
    while (1) {
        bool _success;
        ulong event = read_channel_nb_altera( event_ch, &_success );
        if ( _success ) {
            ulong response;
            // process event and generate response
            write_channel_altera( event_uplink, response );
        }

        // do things
    }
}

kernel void
CmdHub (global ulong * restrict g_request, global ulong * restrict g_response )
{
    ulong request = *g_request;
    write_channel_altera (event_ch, request );
    ulong response = read_channel_altera (event_uplink);
    *g_response = response;
}
