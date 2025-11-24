`timescale 1ns / 1ps
`define SIMULATION

module peripheral_sqrt_TB;
   reg clk;
   reg reset;
   reg start;
   reg [15:0] d_in;
   reg cs;
   reg [4:0] addr;
   reg rd;
   reg wr;
   wire [31:0] d_out;

   // Instancia del periférico
   peripheral_sqrt uut (
      .clk(clk), 
      .reset(reset), 
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
      reset = 0; 
      d_in = 0; 
      addr = 16'h0000; 
      cs = 0; 
      rd = 0; 
      wr = 0;
   end

   // Generación de reloj
   initial clk <= 0;
   always #(PERIOD/2) clk <= ~clk;

   // Secuencia principal de prueba
   initial begin 
      forever begin
         // Reset 
         @(posedge clk);
         reset = 1;
         @(posedge clk);
         reset = 0;
         #(PERIOD*4);

         // ----- Escritura de A -----
         cs = 1; rd = 0; wr = 1;
         d_in = 16'h0441;       // Valor de entrada A (ejemplo)
         addr = 16'h0004;          // Dirección de registro A
         #(PERIOD);
         cs = 0; rd = 0; wr = 0;
         #(PERIOD*3);

         // ----- Escritura de INIT -----
         cs = 1; rd = 0; wr = 1;
         d_in = 16'h0001;       // Activar inicio
         addr = 5'h0C;          // Dirección de registro init
         #(PERIOD);
         cs = 0; rd = 0; wr = 0;
         @ (posedge peripheral_sqrt_TB.uut.sqrt0.done);
         #(PERIOD*17);

         // ----- Lectura de DONE -----
         cs = 1; rd = 1; wr = 0;
         addr = 16'h0014;          // Dirección de done
         #(PERIOD);
         cs = 0; rd = 0; wr = 0;
         #(PERIOD);

         // ----- Lectura de RESULT -----
         cs = 1; rd = 1; wr = 0;
         addr = 16'h0010;          // Dirección de result
         #(PERIOD);
         cs = 0; rd = 0; wr = 0;
         #(PERIOD*30);   
      end
   end

   // Dump de simulación
   initial begin : TEST_CASE
      $dumpfile("peripheral_sqrt_TB.vcd");
      $dumpvars(-1, peripheral_sqrt_TB);
      #(PERIOD*100) $finish;
   end

endmodule
