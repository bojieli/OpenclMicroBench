#define CL_FAIL_CHK(x) if ( x != CL_SUCCESS) { printf ("CL operation failed(%x)!\n", x); return false; }

typedef struct {
	cl_kernel		  Kernel;	
	cl_command_queue  CmdQueue;

	cl_mem            KArg;
} KernelState;

bool LaunchKernel ( KernelState *state, cl_ulong init_arg )
{
    int status;

    state->CmdQueue = clCreateCommandQueue(
            m_Context, 
            m_Device, 
            CL_QUEUE_PROFILING_ENABLE , 
            &status) ;
    CL_FAIL_CHK(status);

    state->Kernel = clCreateKernel (
            m_Program, 
            "worker", 
            &status);
    CL_FAIL_CHK(status);

    status = clSetKernelArg(
            state->Kernel, 
            0, 
            sizeof( cl_ulong ), 
            &init_arg);
    CL_FAIL_CHK(status);

    return true;
}

/* the following function would NOT work */
bool ModifyKernelArg ( KernelState *state, cl_ulong new_arg ) {
    int status;

    status = clSetKernelArg(
            state->Kernel, 
            0, 
            sizeof( cl_ulong ), 
            &new_arg);
    CL_FAIL_CHK(status);

    return true;
}
