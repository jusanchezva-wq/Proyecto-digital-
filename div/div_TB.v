`timescale 1ns / 1ps
`define SIMULATION

module div_TB;

  // Entradas al módulo DUT (Device Under Test)
  reg clk;
  reg rst;
  reg init_in;
  reg [15:0] A;
  reg [15:0] B;

  // Salidas del DUT
  wire [15:0] Result;
  wire done;

  // Instancia del módulo principal
  div div0 (
    .clk(clk),
    .rst(rst),
    .init_in(init_in),
    .A(A),
    .B(B),
    .Result(Result),
    .done(done)
  );

  // Parámetros de tiempo
  parameter PERIOD = 20;
  parameter real DUTY_CYCLE = 0.5;
  parameter OFFSET = 0;
  reg [20:0] i;

  // Eventos de sincronización
  event reset_trigger;
  event reset_done_trigger;

  //------------------------------------------------------------
  // Generador de reset controlado por eventos
  //------------------------------------------------------------
  initial begin 
    forever begin 
      @(reset_trigger);
      @(negedge clk);
      rst = 1;
      @(negedge clk);
      rst = 0;
      -> reset_done_trigger;
    end
  end

  //------------------------------------------------------------
  // Inicialización
  //------------------------------------------------------------
  initial begin
    clk = 0;
    rst = 0;
    init_in = 0;
    A = 16'h0000;
    B = 16'h0001;
  end

  //------------------------------------------------------------
  // Generador de reloj
  //------------------------------------------------------------
  initial begin
    #OFFSET;
    forever begin
      clk = 1'b0;
      #(PERIOD - (PERIOD * DUTY_CYCLE));
      clk = 1'b1;
      #(PERIOD * DUTY_CYCLE);
    end
  end

  //------------------------------------------------------------
  // Secuencia principal de prueba
  //------------------------------------------------------------
  initial begin
    // Activar reset
    #10 -> reset_trigger;
    @(reset_done_trigger);
    @(posedge clk);

    // Primera división: 200 / 10
    A = 16'd200;
    B = 16'd10;
    init_in = 1;
    @(posedge clk);
    init_in = 0;

    // Esperar hasta que termine
    wait(done == 1);
    $display("Tiempo %0t ns -> Resultado 1: %d / %d = %d", $time, A, B, Result);

    // Segunda división: 255 / 7
    @(posedge clk);
    A = 16'd255;
    B = 16'd7;
    init_in = 1;
    @(posedge clk);
    init_in = 0;

    wait(done == 1);
    $display("Tiempo %0t ns -> Resultado 2: %d / %d = %d", $time, A, B, Result);

    // Tercera división: 50 / 25
    @(posedge clk);
    A = 16'd50;
    B = 16'd25;
    init_in = 1;
    @(posedge clk);
    init_in = 0;

    wait(done == 1);
    $display("Tiempo %0t ns -> Resultado 3: %d / %d = %d", $time, A, B, Result);

    // Finalizar simulación
    #100;
    $finish;
  end

  //------------------------------------------------------------
  // Dump de señales para GTKWave
  //------------------------------------------------------------
  initial begin : DUMP
    $dumpfile("div_TB.vcd");
    $dumpvars(-1, uut);
  end

endmodule
