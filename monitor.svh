class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    virtual system_bus_v3 dut_vi;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual system_bus_v3)::get(null, "uvm_test_top", "dut_vi", dut_vi))
            `uvm_fatal("LOG", "Virtual interface not found");
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(posedge dut_vi.clk);
            $display("[LOG] re=%b", dut_vi.re,
                                "we=%b", dut_vi.we,
                                "addr=%x", dut_vi.addr,
                                "data_from=%x", dut_vi.data_from_system,
                                "data_to=%x", dut_vi.data_to_system);
        end
    endtask
endclass: monitor
