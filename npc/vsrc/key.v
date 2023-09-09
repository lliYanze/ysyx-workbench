module key(clk,resetn,ps2_clk,ps2_data,out_buffer, key_clk, num_count);
    input clk,resetn,ps2_clk,ps2_data;
    output reg [7:0] out_buffer;
    output reg key_clk;
    output reg [7:0] num_count;

    reg [9:0] buffer;
    reg [3:0] count;
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
    var next_word = 1;

    always @(posedge clk) begin
        if(resetn == 0) begin
            count <= 0; 
        end
        else begin
            if(sampling) begin
                if(count == 4'd10) begin
                    if((buffer[0] == 0) && (ps2_data == 1) && (^buffer[9:1])) begin
                        if(next_word) begin//如果没有收到f0则一直输出
                            $display("receive %x\n", buffer[8:1]);
                            out_buffer <= buffer[8:1];
                        end else begin //如果接受到f0，就跳过下一个
                            next_word <= 1;
                        end
                        if(buffer[8:1] == 8'b11110000) begin //如果是f0表示松开了一个按键
                            next_word <= 0;
                            out_buffer <= 8'h0;
                            num_count <= num_count + 8'b00000001;
                        end
                        key_clk <= 1'b1; //断码f0反应不过来 所以不会显示
                    end
                    count <= 4'b0000;
                end else begin
                   buffer[count] <= ps2_data;
                   count <= count + 4'b1;
                    key_clk <= 1'b0;
                end
            end
       end
   end


endmodule
