module top(
    input wire[7:0] sw,
    input wire sw_enable,
    output reg no_input,
    output reg [2:0] ledr,
    output reg[7:0] seg0
    
);

wire [2:0] num;


tran_8to3 tran1(.tran_input_wire(sw),
           .tran_enable(sw_enable),
           .tran_all_down(no_input),
           .tran_output_wire(num)
);

digital_led digital_led1(.input_num(num),
    .output_seg(seg0)
);


always @(num) begin
    if(num[0] == 1'b1) begin
        ledr[0] = 1;
    end
    else begin
        ledr[0] = 0;
    end
    if(num[1] == 1'b1) begin
        ledr[1] = 1;
    end
    else begin
        ledr[1] = 0;
    end
    if(num[2] == 1'b1) begin
        ledr[2] = 1;
    end
    else begin
        ledr[2] = 0;
    end
end

endmodule


