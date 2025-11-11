class sequencer extends uvm_sequencer #(pkt, rsp_pkt);
    `uvm_component_utils(sequencer)

    virtual system_bus_v3 dut_vi;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual system_bus_v3)::get(null, "uvm_test_top", "dut_vi", dut_vi))
            `uvm_fatal("LOG", "Virtual interface not found");
    endfunction: build_phase
endclass: sequencer
