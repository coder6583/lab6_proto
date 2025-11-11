class agent extends uvm_agent;
    `uvm_component_utils(agent)

    driver driver_h;
    monitor monitor_h;
    uvm_sequencer #(pkt, rsp_pkt) sequencer_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        driver_h = driver::type_id::create("driver_h", this);
        monitor_h = monitor::type_id::create("monitor_h", this);
        sequencer_h = uvm_sequencer #(pkt, rsp_pkt)::type_id::create("sequencer_h", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
    endfunction: connect_phase
endclass: agent
