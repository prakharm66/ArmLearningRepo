module channel
#(
    DATA_WIDTH = 8
)
(
    location,
    data_in,
    data_out
);
    input integer location;
    input [DATA_WIDTH-1:0] data_in;
    output reg [DATA_WIDTH-1:0] data_out;

    wire [DATA_WIDTH-1:0] mask;

    assign mask = 1'b1 << location;

    always @(*) begin
        data_out = data_in ^ mask;
    end


endmodule

module tb_hamming_7_4();

    reg [3:0] data_in;
    wire [2:0] parity_out;
    wire single_parity;

    reg [3:0] data_in_receiver;
    wire [3:0] data_out_receiver;
    reg [2:0] parity_in_receiver;
    reg single_parity_in_receiver;

    wire single_error_detected;
    wire double_error_detected;
    wire [3:0] data_out;

    integer i;
    integer errLoc;

    hamming_7_4 dut (
        .data_in(data_in),
        .parity_out(parity_out),
        .single_parity(single_parity)
    );

    hamming_receiver receiver (
        .data_in(data_in_receiver),
        .parity_in(parity_in_receiver),
        .single_parity_in(single_parity_in_receiver),
        .single_error_detected(single_error_detected),
        .double_error_detected(double_error_detected),
        .data_out(data_out)
    );


    channel #(8) error_channel (
        .location(errLoc), // This will be set dynamically in the testbench
        .data_in({data_in,parity_out,single_parity}),
        .data_out({data_in_receiver,parity_in_receiver,single_parity_in_receiver})
    );


    initial begin
        // $monitor("Time: %0t, Data In: %b, Parity Out: %b, Single Parity: %b, Single Error Detected: %b, Double Error Detected: %b, Data Out: %b", 
        //          $time, data_in, parity_out, single_parity, single_error_detected, double_error_detected, data_out);

        // $monitor("DataIn Channel: %b, DataOut of Channel: %b, ErrLoc: %d, channel_mask: %b ", data_in, data_in_receiver, errLoc, error_channel.mask);
       
        for (i = 0; i < 16; i = i + 1) begin
            data_in = i[3:0];
            #10;
            // Introduce a single-bit error at a random location

            errLoc = $urandom % 8 ; // Random location between 0 and 3, this bit of data would be flipped
            $display("Data_in: %b, data_in_receiver: %b, data_out_reciever: %b", data_in, data_in_receiver,data_out);

            #10; // Wait for the receiver to process the input
        end

        $finish;
    end

endmodule
