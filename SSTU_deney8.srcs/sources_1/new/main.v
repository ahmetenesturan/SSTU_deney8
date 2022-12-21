`timescale 1ns/1ps

module MAC_Normalize(input [19:0] data, output reg [7:0] result);

    always @(data) begin
        if(data > 255) result = 255;
        else if(data < 0) result = 0;
        else result = data;
    end
endmodule

module CONV(input clk, reset, [23:0] data, [23:0] weight, output [7:0] result);
    wire [19:0] mac_result;
    MAC mac0(clk, reset, data, weight, mac_result);
    MAC_Normalize mac_n0(mac_result, result);
endmodule