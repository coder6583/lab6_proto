class pkt extends uvm_sequence_item;
    `uvm_object_utils(pkt)

    rand bit re, we, rst_n;
    rand bit [31:0] data;
    rand bit [15:0] addr;

    constraint rst_default {rst_n == 1'b1;}

    function new (string name = "");
        super.new(name);
    endfunction: new

endclass: pkt

class rsp_pkt extends uvm_sequence_item;
    `uvm_object_utils(rsp_pkt)

    rand bit [31:0] received;

    function new (string name = "");
        super.new(name);
    endfunction: new
endclass: rsp_pkt
