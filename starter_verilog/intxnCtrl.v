////////////////////////////////////////////////////////////////////////////////
// Filename:    intxnCtrl.v
// Authors:     Carson, Brian, Luke, Jason, Ben
// Date:        30 November 2018
//
// Description: This is the traffic light intersection controller FSM. This
//              module is responsible for maintaining a green light on the
//              north/south highway until a car is detected on the east/west
//              road. In the event that a car is detected, this FSM will cycle
//              the intersection's traffic lights such that the car on the east/
//              west road may safely cross the highway.
//

//         NOTE: reset is active-low


module intxnCtrl(clk, reset_n, car, lights);
	input 				clk, car, reset_n;
	output reg	[5:0]	lights;
	
	reg					reset;
	reg 		[15:0]	Top;
	reg 		[11:0]	Bottom;
	reg			[3:0] 	sec;
	reg			[1:0]	state, prev_state; // 00: GNS, 01: YNS, 10 GEW, 11 YEW; 

initial begin
	Top = 16'h0000;
	Bottom = 12'h000;
	state = 2'b00;
	sec = 4'b0;
	reset = 1'b0;
	lights = 6'b000000;
end
	
always @(posedge clk)begin
	case (state)
		3'b00:
			lights <= 6'b100001;
		3'b01:
			lights <= 6'b010001;
		3'b10:
			lights <= 6'b001100;
		3'b11:
			lights <= 6'b001010;
		default:
			lights <= 6'b111111;
	endcase
end

always @(*)begin
	prev_state = state;
	if(reset_n == 1'b0) begin
		reset <= 1'b1;
		state <= 2'b00;
	end
	else begin
		reset <= 1'b0;
		
		case(state)
			2'b00: begin
				reset <= 1'b1;
				if (car == 1'b1) begin
					state <= 2'b01;
				end
				else begin
					state <= 2'b00;
				end
			end
			2'b01: begin
				if (sec >= 4'd1)begin
					state <= 2'b10;
					//reset <= 1'b1;
				end
				else
					state <= 2'b01;
			end
			2'b10: begin
				if(sec >= 4'd5) begin
					state <= 2'b11;
					//reset <= 1'b1;
				end
				else
					state <= 2'b10;
			end
			2'b11: begin
				if(sec >= 4'd7) begin
					state <= 2'b00;
					//reset <= 1'b1;
				end
				else
					state <= 2'b11;
			end
		endcase
	end
end 
always @(posedge clk or posedge reset)begin
	
	if(reset == 1'b1) begin
		sec <= 4'b0000;
		Top <= 16'h0000;
		Bottom <= 12'h000;
	end
	else if (Top == 16'h2FAF && Bottom == 12'h080) begin
	//else if (Top == 16'h0001 && Bottom == 12'hFFF) begin
		Top <= 16'h0000;
		Bottom <= 12'h000;
		
		sec <= sec + 4'b0001;
	end
	else if(Bottom == 12'hFFF)begin
	//else if(Bottom == 12'hFFF)begin
		Bottom <= 12'h000;
		Top <= Top + 16'h0001;
	end
	else
		Bottom <= Bottom + 12'b000000000001;


end


endmodule
