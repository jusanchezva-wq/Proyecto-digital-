//===========================================================
// Periférico de la raíz cuadrada
//===========================================================
module peripheral_sqrt(
    input clk,
    input reset,
    input [15:0] d_in,
    input cs,
    input [4:0] addr,     // 4 LSB del bus de dirección
    input rd,
    input wr,
    output reg [31:0] d_out
);

//------------------------------------
// Registros internos y señales
//------------------------------------
reg [4:0] s;          // selector del decodificador de dirección
reg [15:0] A;         // entrada A del módulo sqrt
reg init;             // señal de inicio
wire [15:0] result;   // salida del módulo sqrt
wire done;            // fin de operación

//------------------------------------
// Decodificador de dirección
//------------------------------------
always @(*) begin
  if (cs) begin
    case (addr)
      5'h04: s = 5'b00001; // A
      5'h08: s = 5'b00010; // init
      5'h0C: s = 5'b00100; // result
      5'h10: s = 5'b01000; // done
      default: s = 5'b00000;
    endcase
  end else begin
    s = 5'b00000;
  end
end

//------------------------------------
// Escritura de registros
//------------------------------------
always @(posedge clk) begin
  if (reset) begin
    init <= 0;
    A    <= 0;
  end else begin
    if (cs && wr) begin
      A    <= s[0] ? d_in    : A;       // Escribir A
      init <= s[1] ? d_in[0] : init;    // Escribir init (solo bit 0)
    end
  end
end

//------------------------------------
// Multiplexor de salida (lectura)
//------------------------------------
always @(negedge clk) begin
  if (reset)
    d_out = 0;
  else if (cs) begin
    case (s[4:0])
      5'b00100: d_out <= {16'b0, result};     // lectura de result
      5'b01000: d_out <= {31'b0, done};       // lectura de done
    endcase
  end
end

sqrt sqrt0 (
  .clk(clk),
  .rst(reset),
  .init(init),
  .A(A),
  .result(result),
  .done(done)
);

endmodule
