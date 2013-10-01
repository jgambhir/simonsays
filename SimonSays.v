module SimonSays(KEY, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, SW, CLOCK_50, LEDR, LEDG);
	input [3:0] KEY; //user input
	input [1:0] SW;
	input CLOCK_50;
	output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [17:0] LEDR;
	output [8:0] LEDG;
	
	
	reg [3:0] Simon;
	reg [3:0] I; //user input is stored here
	reg [3:0] R;
	reg [4:0] check;
	// initialize R to something non-zero, otherwise the LSFR (linear shift feedback register)
	// will keep giving zeros.
	initial begin
		R <= 4'b0101;
		I <= 4'b0000;
		Simon <= 4'b0001;
	end
	
	// LSFR for pseudo-random binary sequence generation
	always @(posedge SW[0]) begin
		R <= {R[2:0], R[3] ^ R[0]};
		Simon <= {Simon[2:0], Simon[3] ^ Simon[0]}; // same feedback function, different initial value
	end
	//assign LEDR[3:0] = R; //for testing if HEX is outputting the right numbers, or for an easier game.
	display_numbers DN(SW[1], CLOCK_50, R, HEX0);
	
	Show_Simon SS(HEX4, Simon[0]);
	
	assign HEX1 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	assign HEX6 = 7'b1111111;
	assign HEX7 = 7'b1111111;
	
	always @(posedge KEY[3]) begin
		I[3] <= ~I[3];
	end
	always @(posedge KEY[2]) begin
		I[2] <= ~I[2];
	end
	always @(posedge KEY[1]) begin
		I[1] <= ~I[1];
	end
	always @(posedge KEY[0]) begin
		I[0] <= ~I[0];
	end
	
	assign LEDG[7] = I[3];
	assign LEDG[5] = I[2];
	assign LEDG[3] = I[1];
	assign LEDG[1] = I[0];
	
	//evaluate 
	always @ (negedge SW[0]) begin
		if ((I == R & Simon[0]) | I != R & ~Simon[0])
			check <= 1'b1;
		else
			check <= 1'b0;
	end
	
	assign LEDR[11] = ~check;
	assign LEDG[8] = check;
	
endmodule

module Show_Simon(H, S);
	input S;
	output [0:6] H;
	
	assign H[0] = ~S;
	assign H[2] = ~S;
	assign H[3] = ~S;
	assign H[5] = ~S;
	assign H[6] = ~S;
	
	assign H[1] = 1;
	assign H[4] = 1;
endmodule

module display_numbers(EN, clk, R, H);
	input EN, clk;
	input [3:0] R;
	output reg [0:6] H;
	
	reg [1:0] i;
	reg [25:0]count;
	initial begin
		i <= 0;
	end
	
	
	always @ (posedge clk)
	begin
		if (R[i] & EN) begin
			if (i == 3)
				H = 7'b0000110;
			else if (i == 2)
				H = 7'b0010010;
			else if (i == 1)
				H = 7'b1001111;
			else if (i == 0)// i == 0
				H = 7'b0000001;
		end
		else
			H = 7'b1111110;
			
		if (count == 9999999 | ~R[i]) //changes every 1/5 of a second
		begin
						count <= 0;
						if (i == 3)
							i <= 0;
						else
							i <= i + 1;
		end
		else
			begin
			count <= count + 1;
			end
	end
	
endmodule


