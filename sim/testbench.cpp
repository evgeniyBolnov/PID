#include <stdlib.h>
#include "../rtl/obj_dir/Vpid.h"
#include "math.h"

#ifdef VM_TRACE
#include <verilated_vcd_c.h>
#endif

#define COEF 0.001
#define LOW_VALUE -45   
#define SIGNAL_COEF 0.001

int get_temp(int signal) {
  static float valueSpeed, signalSpeed, value = 30;
  static float valueSpeed_f, signalSpeed_f;
	//printf("VS:%f\tSS:%f\tV:%f\n", valueSpeed, signalSpeed, value);
  if (abs(signalSpeed - signal) > 1) {
      if (signalSpeed < signal) signalSpeed += 0.6;
      if (signalSpeed > signal) signalSpeed -= 0.3;
  } else {
      signalSpeed = signal;
  }
  signalSpeed_f += (signalSpeed - signalSpeed_f) * 0.1;
  valueSpeed = signalSpeed_f * SIGNAL_COEF + (LOW_VALUE - value) * COEF;
  value += valueSpeed;
  return value;
}

vluint64_t vtime = 0;
// Called by $time in Verilog
double sc_time_stamp()
{
	return (double)vtime;
}

int main(int argc, char **argv) {
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);

	// Create an instance of our module under test
	Vpid *top_module = new Vpid;

#ifdef VM_TRACE
	VerilatedVcdC* vcd = nullptr;
	const char* flag = Verilated::commandArgsPlusMatch("trace");
	if (flag && 0==strcmp(flag, "+trace"))
	{
		printf("VCD waveforms will be saved!\n");
		Verilated::traceEverOn(true);	// Verilator must compute traced signals
		vcd = new VerilatedVcdC;
		top_module->trace(vcd, 99);	// Trace 99 levels of hierarchy
		vcd->open("out.vcd");		// Open the dump file
	}
#endif
	// switch the clock
	int clock = 0;
	top_module->reset = 0;
	while( !Verilated::gotFinish() )
	{
		vtime+=1;
		if( vtime%2==0){
			clock ^= 1;
			top_module->data = get_temp(top_module->control);
		}
		if( vtime>45 && vtime<=49 )
			top_module->reset = 1;
		else
			top_module->reset = 0;
		top_module->enable = 0;
		top_module->clk = clock;
		top_module->eval();
#ifdef VM_TRACE
		if( vcd )
			vcd->dump( vtime );
#endif
		//printf("%d %02X\n", clock, top_module->q );
		if( vtime>5000000 )
			break;
	}
	top_module->final();
#ifdef VM_TRACE
	if( vcd )
		vcd->close();
#endif
	delete top_module;
	exit(EXIT_SUCCESS);
}