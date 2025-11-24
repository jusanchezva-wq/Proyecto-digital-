module control_sqrt (
    input  clk,
    input  rst,
    input  init,
    input  z,        // Señal del contador (z=1 -> fin)
    input  msb,      // Bit más significativo del comparador
    output reg done,
    output reg ld_tmp,
    output reg r0,
    output reg sh,
    output reg ld,
    output reg lda2
);

    // ============================================================
    // Definición de estados según el diagrama
    // ============================================================
    typedef enum reg [2:0] {
        START      = 3'b000,
        LOAD_TMP   = 3'b001,
        CHECK      = 3'b010,
        LOAD_A2    = 3'b011,
        SHIFT_DEC  = 3'b100,
        CHECK_Z    = 3'b101,
        END1       = 3'b110
    } state_t;

    state_t state, next_state;

    // ============================================================
    // Lógica secuencial de estado
    // ============================================================
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= START;
        else
            state <= next_state;
    end

    // ============================================================
    // Lógica combinacional del FSM
    // ============================================================
    always @(*) begin
        // Valores por defecto
        done   = 0;
        ld_tmp = 0;
        r0     = 0;
        sh     = 0;
        ld     = 0;
        lda2   = 0;
        next_state = state;

        case (state)

            // -------------------------
            // Estado inicial
            // -------------------------
            START: begin
                if (init)
                    next_state = SHIFT_DEC;
                else
                    next_state = START;
            end

            // -------------------------
            // Carga temporal
            // -------------------------
            LOAD_TMP: begin
                ld_tmp = 1;
                next_state = CHECK;
            end

            // -------------------------
            // Comparación del MSB
            // -------------------------
            CHECK: begin
                if (msb)
                    next_state = CHECK_Z;
                else
                    next_state = LOAD_A2;
            end

            // -------------------------
            // Carga A2 si MSB = 0
            // -------------------------
            LOAD_A2: begin
                lda2 = 1;
                r0   = 1;
                next_state = CHECK_Z;
            end

            // -------------------------
            // Desplaza y decrementa
            // -------------------------
            SHIFT_DEC: begin
                sh = 1;
                next_state = LOAD_TMP;
            end

            // -------------------------
            // Verificación del fin (z)
            // -------------------------
            CHECK_Z: begin
                if (z)
                    next_state = END1;
                else
                    next_state = SHIFT_DEC;
            end

            // -------------------------
            // Estado final
            // -------------------------
            END1: begin
                done = 1;
                next_state = END1; // permanece hasta reset
            end

            default: next_state = START;

        endcase
    end

endmodule
