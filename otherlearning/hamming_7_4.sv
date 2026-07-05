//defining the H matrix first
//I would try to use this H matrix to generate 3 parity bits for 4 bit data
//since it is only 3 bits, not many combinations are possible, only one is there
// H =[1 1 0 1 1 0 0 ],
//    [1 0 1 1 0 1 0 ],
//    [0 1 1 1 0 0 1 ]   
// bit sequence is D0 D1 D2 D3 P0 P1 P0 

// I am assuming there are only single bit or max 2 bit flip

module hamming_7_4(
    input [3:0] data_in, // 4-bit input data
    output reg [2:0] parity_out, // 3-bit output parity vector 
    output reg single_parity
);

    always @(*) begin
        // Calculate parity bits based on the H matrix
        parity_out[0] = data_in[0] ^ data_in[1] ^ data_in[3]; // P0
        parity_out[1] = data_in[0] ^ data_in[2] ^ data_in[3]; // P1
        parity_out[2] = data_in[1] ^ data_in[2] ^ data_in[3]; // P2
        single_parity = ^{data_in,parity_out}; // Calculate single parity bit
    end

endmodule

module hamming_receiver(
    input [3:0] data_in, // 4-bit input data
    input [2:0] parity_in, // 3-bit input parity vector
    input single_parity_in, // Single parity bit input
    output single_error_detected, // Output indicating if a single error is detected
    output double_error_detected, // Output indicating if a double error is detected
    output [3:0]data_out // Output data after error correction
);

    reg [2:0]syndrome;
    wire [7:0]code_word;
    wire received_single_parity;

    assign code_word = {data_in,parity_in,single_parity_in};
    assign received_single_parity = ^code_word;

    always @(*) begin
        syndrome = {data_in[0] ^ data_in[1] ^ data_in[3] ^ parity_in[0],
                    data_in[0] ^ data_in[2] ^ data_in[3] ^ parity_in[1],
                    data_in[1] ^ data_in[2] ^ data_in[3] ^ parity_in[2]
        }; 
    end

    //different parity, odd number of flips,hence single bit flip
    assign single_error_detected = ~(received_single_parity ^ single_parity_in );
    
    //single error was not detected but syndrome tells bit flip
    assign double_error_detected = ~single_error_detected && (|(syndrome));

    reg [3:0] mask; 

    always @(*) begin 
    case (syndrome)
        3'b110:  mask = 4'b0001;
        3'b101:  mask = 4'b0010;
        3'b011:  mask = 4'b0100;
        3'b111:  mask = 4'b1000;
        default: 
                 mask = 4'b0000;
    endcase
    end

    //flipping the error bit
    assign data_out = data_in ^ mask;


endmodule


