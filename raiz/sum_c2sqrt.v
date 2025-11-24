module addc2 (
    input  [15:0] A,
    input  [15:0] B,
    output [15:0] RES,
    output        MSB
);
    wire [15:0] B_c2; //Complemento a 2 de B
    wire [15:0] sum;

    assign B_c2 = ~B + 16'b1;

    // Resultado de la suma (A + B_c2)
    assign sum = A + B_c2;

    // Salidas
    assign RES = sum;
    assign MSB = sum[15];  

endmodule
