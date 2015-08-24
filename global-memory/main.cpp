typedef struct {
	cl_kernel		  Kernel;	
	cl_command_queue  CmdQueue;

	cl_mem            ReqQueue;
	cl_mem            CompleteQueue;
} KernelState;

bool SignalKernel ( KernelState *sta, cl_ulong event, cl_ulong* outevent ) { 
    cl_int status; 

    status = clEnqueueWriteBuffer( 
        sta->CmdQueue, 
        sta->ReqQueue, 
        CL_TRUE, 
        0, 
        sizeof(event), 
        event, 
        0, 
        NULL, 
        NULL 
    ); 
    CL_FAIL_CHK(status); 
    clFinish (sta->CmdQueue); 

    status = clEnqueueTask( 
        sta->CmdQueue, 
        sta->Kernel, 
        0, 
        NULL, 
        NULL ); 
    CL_FAIL_CHK(status); 
    clFinish ( sta->CmdQueue ); 

    status = clEnqueueReadBuffer( 
        sta->CmdQueue, 
        sta->CompleteQueue, 
        CL_TRUE, 
        0, 
        sizeof(cl_ulong), 
        outevent, 
        0, 
        NULL, 
        NULL 
    ); 
    CL_FAIL_CHK(status); 
    clFinish ( sta->CmdQueue ); 
    return true; 
} 

bool CreateCommandHub ( KernelState *state )
{
    state->CmdQueue = clCreateCommandQueue(
            m_Context, 
            m_Device, 
            CL_QUEUE_PROFILING_ENABLE , 
            &status) ;
    CL_FAIL_CHK(status);

    state->Kernel = clCreateKernel (
            m_Program, 
            "CmdHub", 
            &status);
    CL_FAIL_CHK(status);

    state->ReqQueue = clCreateBuffer( 
            m_Context, 
            CL_MEM_READ_WRITE, 
            sizeof( ClSignal), 
            NULL, 
            &status);
    CL_FAIL_CHK(status);		

    state->CompleteQueue = clCreateBuffer( 
            m_Context, 
            CL_MEM_READ_WRITE, 
            sizeof( ClSignal), 
            NULL, 
            &status);
    CL_FAIL_CHK(status);

    status = clSetKernelArg(
            state->Kernel, 
            0, 
            sizeof(cl_mem), 
            &state->ReqQueue);
    CL_FAIL_CHK(status);

    status = clSetKernelArg(
            state->Kernel, 
            1, 
            sizeof(cl_mem), 
            &state->CompleteQueue);
    CL_FAIL_CHK(status);

    return true;
}
