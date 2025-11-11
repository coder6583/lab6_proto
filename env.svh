class env extends uvm_env;
    `uvm_component_utils(env)

    agent agent_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent_h = agent::type_id::create("agent_h", this);
    endfunction: build_phase
endclass: env
