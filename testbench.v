
`timescale 1ns/1ps

module tb_train_system;
    // Inputs
    reg [9:0] pos1, pos2;
    reg [7:0] speed1, speed2;
    reg dir1, dir2;
    reg [1:0] track_condition1, track_condition2;

    // Outputs from train_info
    wire [9:0] o_pos1, o_pos2;
    wire [7:0] o_speed1, o_speed2;
    wire o_dir1, o_dir2;

    // Outputs from collision detector
    wire alert, brake;

    // Outputs from speed controller
    wire [7:0] ctrl_speed1, ctrl_speed2;

    // Instantiate train info
    train_info trainA (.position(pos1), .speed(speed1), .dir(dir1),
                       .out_position(o_pos1), .out_speed(o_speed1), .out_dir(o_dir1));
                       
    train_info trainB (.position(pos2), .speed(speed2), .dir(dir2),
                       .out_position(o_pos2), .out_speed(o_speed2), .out_dir(o_dir2));

    // Collision detector
    collision_detector detector (.pos1(o_pos1), .pos2(o_pos2),
                                 .speed1(o_speed1), .speed2(o_speed2),
                                 .dir1(o_dir1), .dir2(o_dir2),
                                 .alert(alert), .brake(brake));

    // Speed control based on track condition
    train_speed_controller controller1 (.track_condition(track_condition1), .train_speed(ctrl_speed1));
    train_speed_controller controller2 (.track_condition(track_condition2), .train_speed(ctrl_speed2));

    initial begin
        $display("Time | Pos1 | Pos2 | Spd1 | Spd2 | Dir1 | Dir2 | Tcond1 | Tcond2 | CSpd1 | CSpd2 | Alert | Brake");
        $monitor("%0dns | %4d | %4d | %4d | %4d |  %b   |  %b   |   %b    |   %b    |  %4d  |  %4d  |   %b   |   %b",
                  $time, pos1, pos2, speed1, speed2, dir1, dir2,
                  track_condition1, track_condition2, ctrl_speed1, ctrl_speed2,
                  alert, brake);

        // Test 1: Safe same direction
        #5;
        pos1 = 100; speed1 = 40; dir1 = 0; track_condition1 = 2'b10;
        pos2 = 200; speed2 = 60; dir2 = 0; track_condition2 = 2'b00;
        #10;

        // Test 2: Rear-End Collision
        pos1 = 100; speed1 = 40; dir1 = 0; track_condition1 = 2'b01;
        pos2 = 115; speed2 = 60; dir2 = 0; track_condition2 = 2'b11;
        #10;

        // Test 3: Head-On Collision
        pos1 = 500; speed1 = 60; dir1 = 0; track_condition1 = 2'b00;
        pos2 = 510; speed2 = 60; dir2 = 1; track_condition2 = 2'b01;
        #10;

        // Test 4: Opposite safe
        pos1 = 100; speed1 = 40; dir1 = 0; track_condition1 = 2'b10;
        pos2 = 300; speed2 = 40; dir2 = 1; track_condition2 = 2'b10;
        #10;

        // Test 5: Rear-end Safe
        pos1 = 100; speed1 = 60; dir1 = 0; track_condition1 = 2'b10;
        pos2 = 150; speed2 = 70; dir2 = 0; track_condition2 = 2'b10;
        #10;

        $finish;
    end
endmodule
