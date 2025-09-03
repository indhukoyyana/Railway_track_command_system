module train_info (
    input [9:0] position,
    input [7:0] speed,
    input dir,
    output [9:0] out_position,
    output [7:0] out_speed,
    output out_dir
);
    assign out_position = position;
    assign out_speed = speed;
    assign out_dir = dir;
endmodule

module collision_detector (
    input [9:0] pos1, pos2,
    input [7:0] speed1, speed2,
    input dir1, dir2,
    output reg alert,
    output reg brake
);
    parameter SAFE_DISTANCE = 20;

    always @(*) begin
        alert = 0;
        brake = 0;

        // Head-on
        if (dir1 != dir2 && (pos1 > pos2 ? (pos1 - pos2) : (pos2 - pos1)) < SAFE_DISTANCE) begin
            alert = 1;
            brake = 1;
        end
        // Rear-end
        else if (dir1 == dir2) begin
            if ((pos1 > pos2 && speed2 > speed1 && (pos1 - pos2) < SAFE_DISTANCE) || 
                (pos2 > pos1 && speed1 > speed2 && (pos2 - pos1) < SAFE_DISTANCE)) begin
                alert = 1;
                brake = 1;
            end
        end
    end
endmodule


module train_speed_controller (
    input [1:0] track_condition,  // 00: Uphill, 01: Curve, 10: Normal, 11: Slippery
    output reg [7:0] train_speed
);
    always @(*) begin
        case (track_condition)
            2'b00: train_speed = 80;
            2'b01: train_speed = 50;
            2'b10: train_speed = 60;
            2'b11: train_speed = 40;
            default: train_speed = 0;
        endcase
    end
endmodule
