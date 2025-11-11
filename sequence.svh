typedef enum logic [1:0] {FIFO = 2'b10, LIFO = 2'b01} queue_mode;

class reset_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(reset_seq)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body;
        pkt tx;
        tx = pkt::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {
            data == 'b0; addr == 'b0;
            re == 1'b0; we == 1'b0; });
        tx.rst_n = 1'b0;
        finish_item(tx);
    endtask: body
endclass: reset_seq

class read_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(read_seq)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body;
        pkt tx;
        tx = pkt::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {
            re == 1'b1; we == 1'b0;});
        finish_item(tx);
    endtask: body
endclass: read_seq

class valid_read_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(valid_read_seq)

    parameter BASE_CFG = 0;
    parameter BASE_STATUS = 10;
    parameter BASE_DATA = 15;

    parameter FIFO_LENGTH = 32;

    rsp_pkt rsp;

    rand bit [15:0] addr;
    constraint valid {addr dist {BASE_CFG:=20, BASE_STATUS:=20, [BASE_DATA: BASE_DATA + FIFO_LENGTH]:=20}; }

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body;
        pkt tx;
        tx = pkt::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {
            re == 1'b1; we == 1'b0; });
        tx.addr = addr;
        finish_item(tx);
        get_response(rsp);
    endtask: body
endclass: valid_read_seq

class write_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(write_seq)

    parameter BASE_CFG = 0;

    rand queue_mode mode;

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body;
        pkt tx;
        tx = pkt::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {
            addr == BASE_CFG;
            re == 1'b0; we == 1'b1; });
        tx.data = {29'b0, mode, 1'b0};
        finish_item(tx);
    endtask: body
endclass: write_seq

class exec_seq extends uvm_sequence #(pkt, rsp_pkt);
    `uvm_object_utils(exec_seq)

    parameter BASE_CMD = 99;

    rand bit [31:0] data;
    rand int operation;

    constraint valid_op {
        operation inside {OP_NOP, OP_PUSH, OP_POP, OP_STREAM, OP_LAST};}

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body;
        pkt tx;
        tx = pkt::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {
            data == data; addr == BASE_CMD + operation;
            re == 1'b0; we == 1'b1; });
        finish_item(tx);
    endtask: body
endclass: exec_seq

