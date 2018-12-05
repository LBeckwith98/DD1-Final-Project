////////////////////////////////////////////////////////////////////////////////
// Filename:    trafficLightTop.v
// Authors:     Carson, Brian, Luke, Jason, Ben
// Date:        30 November 2018
//
// Description: This is the top-level module for our final project in ECE 3544.
//              This traffic light controller handles three analog inputs
//              via three separate buttons on our development board and,
//              according to those inputs, it produces some analog output which
//              is visible via six separate LEDs on our development board.
//
//              The three buttons in use handle the reset, eastern car arrival,
//              & western car arrival - KEY[0], KEY[1], and KEY[2] respectively.
//              Resetting of the system is asyncronous. The six LEDs in use
//              act as the traffic lights themselves: two sets of three LEDs
//              each represent the east/west & north/south traffic lights.
//

module trafficLightTop(CLOCK_50, KEY, LED);

   input        CLOCK_50;
   input [2:0]  KEY;
   output [9:0] LED;

   wire       car_east, car_west, car_ew;
   wire [5:0] street_lights;

   keypressed K1 (.clock(CLOCK_50),             // 50 MHz FPGA Clock
                  .reset(KEY[0]),               // KEY0 is the system reset - ACTIVE LOW
                  .enable_in(KEY[1]),           // KEY1 provides the eastern car input
                  .enable_out(car_east));       // Output connects to OR gate

   keypressed K2 (.clock(CLOCK_50),             // 50 MHz FPGA Clock
                  .reset(KEY[0]),               // KEY0 is the system reset - ACTIVE LOW
                  .enable_in(KEY[2]),           // KEY2 provides the western car input
                  .enable_out(car_west));       // Output connects to OR gate

   or CAR1 (car_ew,                             // Output connects to intxn cntrl
            car_east,                           // Input high if a car waits on the east side
            car_west);                          // Input high if a car waits on the west side

   intxnCtrl INT1 (.clk(CLOCK_50),            // 50 MHz FPGA Clock
                   .reset_n(KEY[0]),            // KEY0 is the system reset - ACTIVE LOW
                   .car(car_ew),       // High OR'd input drives the traffic light FSM
                   .lights(street_lights)); // FSM output connects to the LED lights

   assign LED = { street_lights[5], street_lights[4],  street_lights[3],            // MSBs toggle east-west lights
                  3'b000,                         // Leaving the middle LEDs unused
                  street_lights[2], street_lights[1],  street_lights[0]            // LSBs toggle north-south lights
                };

endmodule

