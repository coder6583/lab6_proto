class fill_test extends uvm_test;
    `uvm_component_utils(fill_test)

    virtual system_bus_v3 dut_vi;
    env env_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env_h = env::type_id::create("env_h", this);
        if (!uvm_config_db #(virtual system_bus_v3)::get(null, "uvm_test_top", "dut_vi", dut_vi))
            `uvm_fatal("LAB2TEST", "Virtual interface not found");
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        write_seq conf_fifo = write_seq::type_id::create("conf");
        reset_seq rst;
        fill_then_fill_seq fill_then_fill;
        conf_fifo.mode = FIFO;
        rst = reset_seq::type_id::create("rst");
        fill_then_fill = fill_then_fill_seq::type_id::create("fill_then_fill");
        phase.raise_objection(this);
        rst.start(env_h.agent_h.sequencer_h);
        conf_fifo.start(env_h.agent_h.sequencer_h);
        fill_then_fill.start(env_h.agent_h.sequencer_h);
        phase.drop_objection(this);
    endtask
endclass: fill_test

class fill_empty_test extends uvm_test;
    `uvm_component_utils(fill_empty_test)

    virtual system_bus_v3 dut_vi;
    env env_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env_h = env::type_id::create("env_h", this);
        if (!uvm_config_db #(virtual system_bus_v3)::get(null, "uvm_test_top", "dut_vi", dut_vi))
            `uvm_fatal("LAB2TEST", "Virtual interface not found");
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        write_seq conf_fifo;
        reset_seq rst;
        fill_empty_fill_seq fill_empty_fill;
        conf_fifo = write_seq::type_id::create("conf");
        conf_fifo.mode = FIFO;
        rst = reset_seq::type_id::create("rst");
        fill_empty_fill = fill_empty_fill_seq::type_id::create("fill_empty_fill");
        phase.raise_objection(this);
        rst.start(env_h.agent_h.sequencer_h);
        conf_fifo.start(env_h.agent_h.sequencer_h);
        fill_empty_fill.start(env_h.agent_h.sequencer_h);
        phase.drop_objection(this);
    endtask
endclass: fill_empty_test

class random_seq_test extends uvm_test;
    `uvm_component_utils(random_seq_test)

    env env_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env_h = env::type_id::create("env_h", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        repeat_random_seq repeat_rand;
        repeat_rand = repeat_random_seq::type_id::create("repeat_rand");
        assert(repeat_rand.randomize());
        phase.raise_objection(this);
        repeat_rand.start(env_h.agent_h.sequencer_h);
        phase.drop_objection(this);
    endtask
endclass: random_seq_test

