`timescale 1ns/1ps

module MAC_Normalize(input [19:0] data, output reg [7:0] result);

    always @ *
    begin
        if(data > 255)
            result = 255;
        else if(data < 0)
            result = 0;
        else
            result = data;
    end
endmodule

module CONV(input clk, reset, [23:0] data, [23:0] weight, output [7:0] result);
    wire [19:0] mac_result;
    MAC mac0(clk, reset, data, weight, mac_result);
    MAC_Normalize mac_n0(mac_result, result);
endmodule

module CONV128
(
    input clk,
    input reset,
    input [1039:0] data,
    input [23:0] weight,
    output [1023:0] result
);
    wire [7:0] result_vec [127:0];
    
    genvar i;
    generate
    begin
        for(i = 0; i < 128; i = i + 1)
        begin
            CONV CONV(clk, reset, data[23 + i*8 : 0 + i*8], weight, result_vec[i][7:0]);
            assign result[7 + i*8 : 0 + i*8] = result_vec[i];
        end
    end
    endgenerate

endmodule

module control_input
(
    input clk,
    input reset,
    input conv_run,
    input [71:0] kernel,
    output reg conv_reset,
    output reg enable_ram,
    output reg [7:0] address_ram,
    output reg [23:0] weight);

    reg [1:0] counter;
    
    always @ (posedge clk or posedge reset) begin
        if(reset)
            counter <= 0;
        else begin
            if(counter < 3)
                counter <= counter + 1;
            else
                counter <= 0;
        end
    end

    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            address_ram <= 0;
            enable_ram <= 0;
            conv_reset <= 1;
        end
        else begin
            if(conv_run) begin
                case(counter)
                    0: begin
                        weight <= kernel [23:0];
                        conv_reset <= 0;
                        address_ram <= address_ram + 1;
                        enable_ram <= 1;
                    end
                    1: begin
                        weight <= kernel [47:24];
                        conv_reset <= 0;
                        address_ram <= address_ram + 1;
                        enable_ram <= 1;
                    end
                    2: begin
                        weight <= kernel [71:48];
                        conv_reset <= 0;
                        address_ram <= address_ram + 1;
                        enable_ram <= 1;
                    end
                    3: begin
                        conv_reset <= 1;
                        enable_ram <= 1;
                        address_ram <= address_ram - 2;
                    end
                endcase
            end
        end
    end
endmodule


module control_output
(
    input clk,
    input reset,
    input [1023:0] data,
    output reg conv_done,
    output reg [7:0] ram_address,
    output reg [1023:0] data_out);

    reg [1:0] counter;
    always @ (posedge clk or posedge reset) begin
        if(reset)
            counter <= 0;
        else begin
            if(counter < 3)
                counter <= counter + 1;
            else
                counter <= 0;
        end
    end
    
    always @ (posedge clk or posedge reset)
    begin
        if(reset) begin
            data_out <= 0;
            ram_address <= 0;
            conv_done <= 0;
        end
        else begin
            case(counter)
                0: begin
                
                end
                1: begin
                
                end
                3: begin
                    data_out <= data;
                    ram_address <= ram_address + 1;
                    if(ram_address == 128)
                        conv_done <= 1;
                end
                2: begin
                
                end
            endcase
        end
    end
endmodule
