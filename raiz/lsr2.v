module lsr2 (
    input clk,
    input rst_ld,
    input shift,
    input lda2,
    input [15:0] in_R1,  // Entrada para A
    input [15:0] in_R2,  // Entrada para R
    output reg [15:0] out_R,      // Salida R
    output reg [15:0] lda2_out    // Salida A
);

    // Registros internos
    reg [15:0] A;
    reg [15:0] R;

    always @(posedge clk or posedge rst_ld) begin
        if (rst_ld) begin
            A <= 16'b0;
            R <= 16'b0;
        end 
        else if (lda2) begin
            // Carga de A (cuando se habilita lda2)
            A <= in_R1;
        end
        else if (shift) begin
            // Desplazamiento: A se mueve dos posiciones a la izquierda
            A <= A << 2;
            // R se mueve una posición a la izquierda
            R <= R << 1;
        end
        else begin
            // Mantiene los valores actuales
            A <= A;
            R <= R;
        end
    end

    // Salidas actualizadas
    always @(*) begin
        lda2_out = A;
        out_R = R;
    end

endmodule
