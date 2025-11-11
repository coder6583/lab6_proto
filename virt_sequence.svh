class fill_queue_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(fill_queue_seq)

    function new (string name = "fill_queue_seq");
        super.new(name);
    endfunction

    virtual task body();
        exec_seq push;
        repeat(32) begin
            `uvm_do_with(push, {operation == OP_PUSH;});
        end
    endtask
endclass: fill_queue_seq

class empty_queue_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(empty_queue_seq)

    function new (string name = "empty_queue_seq");
        super.new(name);
    endfunction

    virtual task body();
        exec_seq push;
        repeat(32) begin
            `uvm_do_with(push, {operation == OP_POP;});
        end
    endtask
endclass: empty_queue_seq

class stream_until_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(stream_until_seq)

    parameter BASE_STATUS = 10;

    rsp_pkt rsp;
    virtual system_bus_v3 dut_vi;

    function new (string name = "exec_until_seq");
        super.new(name);
    endfunction

    virtual task body();
        exec_seq stream;
        valid_read_seq read_status;
        read_status = valid_read_seq::type_id::create("valid_read_seq");
        read_status.addr = BASE_STATUS;
        repeat(1000) begin
            read_status.start(m_sequencer, this);
            if (read_status.rsp.received[2] != 1'b1) begin
                break;
            end
        end
    endtask
endclass: stream_until_seq

class fill_then_fill_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(fill_then_fill_seq)

    virtual system_bus_v3 dut_vi;

    function new (string name = "fill_then_fill_seq");
        super.new(name);
    endfunction

    virtual task body();
        fill_queue_seq fill;
        `uvm_do(fill);
        `uvm_do(fill);
    endtask
endclass: fill_then_fill_seq

class fill_empty_fill_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(fill_empty_fill_seq)

    virtual system_bus_v3 dut_vi;

    function new (string name = "fill_empty_fill_seq");
        super.new(name);
    endfunction

    virtual task body();
        fill_queue_seq fill;
        empty_queue_seq empty;
        `uvm_do(fill);
        `uvm_do(empty);
        `uvm_do(fill);
    endtask
endclass: fill_empty_fill_seq

class random_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(random_seq)

    parameter BASE_STATUS = 10;

    virtual system_bus_v3 dut_vi;

    rand int seq_sel;
    constraint weighted {seq_sel dist { 0:=10, 1:=30, [2:7]:=80, [8:9]:=20};}

    function new (string name = "random_seq");
        super.new(name);
    endfunction

    virtual task body();
        reset_seq reset;
        read_seq read;
        valid_read_seq valid_read;
        write_seq write;
        exec_seq exec;
        fill_queue_seq fill;
        empty_queue_seq empty;
        stream_until_seq stream;
        fill_then_fill_seq fill_then_fill;
        fill_empty_fill_seq fill_empty_fill;

        case (seq_sel)
            0: begin
                `uvm_do(reset);
            end
            1: begin
                `uvm_do(read);
            end
            2: begin
                `uvm_do(valid_read);
            end
            3: begin
                `uvm_do(write);
            end
            4: begin
                `uvm_do(exec);
            end
            5: begin
                `uvm_do(fill);
            end
            6: begin
                `uvm_do(empty);
            end
            7: begin
                `uvm_do(stream);
            end
            8: begin
                `uvm_do(fill_then_fill);
            end
            9: begin
                `uvm_do(fill_empty_fill);
            end
        endcase
    endtask
endclass: random_seq

class repeat_random_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(repeat_random_seq)

    rand int cnt;
    constraint limit {cnt == 1000;}

    function new(string name = "repeat_random_seq");
        super.new(name);
    endfunction

    virtual task body();
        random_seq seq;
        repeat(cnt) begin
            `uvm_do(seq);
        end
    endtask
endclass: repeat_random_seq
