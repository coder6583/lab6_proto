class driver extends uvm_driver #(pkt, rsp_pkt);
    `uvm_component_utils(driver)

    virtual system_bus_v3 dut_vi;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual system_bus_v3)::get(null, "uvm_test_top", "dut_vi", dut_vi))
            `uvm_fatal("LOG", "Virtual interface not found");
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        rsp_pkt rsp;
        pkt tx;
        forever begin
            seq_item_port.get_next_item(tx);
            @(posedge dut_vi.clk);
            dut_vi.addr <= tx.addr;
            dut_vi.data_from_system <= tx.data;
            dut_vi.re <= tx.re;
            dut_vi.we <= tx.we;
            dut_vi.rst_n <= tx.rst_n;

            rsp = rsp_pkt::type_id::create("rsp");
            rsp.received = dut_vi.data_to_system;
            rsp.set_id_info(tx);
            seq_item_port.item_done(rsp);
        end
    endtask: run_phase
endclass: driver
