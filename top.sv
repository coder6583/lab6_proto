`default_nettype none

`include "package.pkg"

module top;

    import uvm_pkg::*;
    import pkg::*;

    system_bus_v3 bus();
    streaming_engine_v3 dut(.bus(bus));

    initial begin
        bus.clk = 0;
        forever #50 bus.clk = ~bus.clk;
    end

    initial begin
        uvm_config_db #(virtual system_bus_v3)::set(null, "uvm_test_top", "dut_vi", bus);
        run_test();
    end
endmodule : top
