`timescale 1ns / 1ps
`define SIMULATION

module peripheral_bin2bcd_TB;

   reg clk;
   reg rst;
   reg [31:0] d_in;
   reg cs;
   reg [4:2] addr;
   reg rd;
   reg wr;
   wire [31:0] d_out;

   // Instancia del periférico
   peripheral_bin2bcd uut (
      .clk(clk),
      .rst(rst),
      .d_in(d_in),
      .cs(cs),
      .addr(addr),
      .rd(rd),
      .wr(wr),
      .d_out(d_out)
   );

   parameter PERIOD = 20;

   // Inicialización de señales
   initial begin  
      clk = 0; 
      rst = 0; 
      d_in = 0; 
      addr = 3'b000; 
      cs = 0; 
      rd = 0; 
      wr = 0;
   end

   // Generación del reloj
   always #(PERIOD/2) clk = ~clk;

   // Secuencia principal de prueba
   initial begin 
      forever begin
         // Reset 
         @(negedge clk);
         rst = 1;
         @(negedge clk);
         rst = 0;
         #(PERIOD*4);

         // ----- Escritura de número binario -----
         cs = 1; rd = 0; wr = 1;
         d_in = 32'h00000FA0;    // 4000 decimal (valor de ejemplo)
         addr = 3'b000;          // dirección del número de entrada
         #(PERIOD);
         cs = 0; wr = 0; rd = 0;
         #(PERIOD*3);

         // ----- Escritura de INIT -----
         cs = 1; rd = 0; wr = 1;
         d_in = 32'h00000001;    // activar inicio
         addr = 3'b001;          // dirección de init
         #(PERIOD);
         cs = 0; wr = 0; rd = 0;
         #(PERIOD*17);

         // ----- Lectura de READY -----
         cs = 1; rd = 1; wr = 0;
         addr = 3'b010;          // dirección ready
         #(PERIOD);
         cs = 0; rd = 0; wr = 0;
         #(PERIOD);

         // ----- Lectura de RESULT_DN -----
         cs = 1; rd = 1; wr = 0;
         addr = 3'b011;          // dirección result_dn
         #(PERIOD);
         cs = 0; rd = 0; wr = 0;
         #(PERIOD);

         // ----- Lectura de RESULT_UP -----
         cs = 1; rd = 1; wr = 0;
         addr = 3'b100;          // dirección result_up
         #(PERIOD);
         cs = 0; rd = 0; wr = 0;
         #(PERIOD*20);
      end
   end

   // Archivo de simulación
   initial begin : TEST_CASE
      $dumpfile("peripheral_bin2bcd_TB.vcd");
      $dumpvars(-1, peripheral_bin2bcd_TB);
      #(PERIOD*200) $finish;
   end

endmodule
