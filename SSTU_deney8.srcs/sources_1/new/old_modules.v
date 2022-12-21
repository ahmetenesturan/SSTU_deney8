`timescale 1ns/1ps

module MULTB (input signed [7:0] A, input signed [7:0] X, output reg signed [15:0] result);

    always @(A or X) begin
        result <= A * X;
    end

endmodule

module ADDRB #(parameter a_size = 16, parameter  b_size = 16, parameter c_size = 16) (input  signed [(a_size-1):0] A, input signed [(b_size-1):0] B, output reg signed [(c_size-1):0] result);

    always @(A or B) begin
        result <= A + B;
    end

endmodule

module MAC (input clk, reset, input [23:0] data, input [23:0] weight, output reg [19:0] result);

    wire signed [15:0] product0, product1, product2;
    wire signed [19:0] sum0, sum1;
    reg [1:0] count;

    MULTB m0(data[7:0], weight[7:0], product0);
    MULTB m1(data[15:8], weight[15:8], product1);
    MULTB m2(data[23:16], weight[23:16], product2);

    ADDRB #(.c_size(20)) a0(product0, product1, sum0);
    ADDRB #(.b_size(20), .c_size(20)) a1(product2, sum0, sum1);

    always @(posedge clk or posedge reset)begin
        if(reset == 1) begin
            result <= 0;
            count <= 0;
        end
        else begin
            result <= result + sum1;
            count <= count + 1;
        end
        
    end


endmodule