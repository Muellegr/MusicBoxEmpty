
/*

This is a empty template for the DE10 lite.   Has a lot of premade stuff added to help FFT dev.

	MISC STUFF

	input  wire [9:0] max10board_switches;
		The numbers in brackets is how many bits it has + 1.
		so that actually describes 10 different array indexes.  0 - 9 is 10 spots. 

		Can use max10board_switches[0]   to select a specific bit, sort of like an array.

		Can combine multiple switches into a single value.
		wire [4:0] example ;   // 5 unique bits
		assign example = max10board_switches[4:0];   //Pulls the 5 right-most bits and assigns them to example.  Example is now the first 5 switches.
		-----------------------
		wire [3:0] extra; //4 unique bits
		assign extra = 4'd10;  //When doing # ' d    , # describes the total number of bits. 
			there's 4'h   for hex, and 4'b  for binary
				Quartus can do this for you automatically.  If you do    assign extra = 10     works.
				But you might make a mistake if you trust it.   assign extra = 240000       extra still has only 4 bits.  It'll convert 240000 to binary, and use the 4 right most bits.  
					That last point has bitten me a bunch.

			So [#:0]  think array index range.  #'dVALUE    think actual bits.

	output wire	[5:0][6:0]	max10Board_LEDSegments;//The DE-10 Board LED Segments
		2D array.
		max10Board_LEDSegments[0] = 7'b1111_100 ;      
			There's 6 displays, each one with 7 characters.  
			 wire [arrayCount:0] [bitSizePerIndex:0] varName;      
			 	Numbers are still describe index positions.
		Can also do max10Board_LEDSegments[0][6]  to get the 7th array index of segment0.
			[0][7] doesn't exist.  No idea what this behavour would be.


	---------------------------------------
	microphoneInputSample   is a 8-bit variable.  
	This simulates the SPI-input 'seeing' a specific sinewave.  This value is always changing and rides up and down a sinewave from 0 to 255.  

	----------------------------------------
	segmentDisplay_DisplayValue  is a single variable that displays a 6-digit number on the display.
	This is really simple to use. Litterally set it to whatever you want, and the 6-digits will display it.

	assign segmentDisplay_DisplayValue = microphoneInputSample;
		You will see a number range of 0 to 255 on the display.  
		Might be a blur if you have >100Hz.  
	Or you can do assign segmentDisplay_DisplayValue = 999999   and it'll display that.  
	If you do segmentDisplayValue = 200'd52359812948793257    it'll take the 20 right-most bits and display.  It probably won't display '793257'.  
*/
module Main(
	//GPIO
	max10Board_50MhzClock,
	//DE10LITE DEDICATED
	max10Board_Buttons,
	max10board_switches,
	max10Board_LEDSegments,
	max10Board_LED

);
	/////////////////////////////////////////////////////////
	input  wire	max10Board_50MhzClock;
	output wire	[5:0][6:0]	max10Board_LEDSegments;//The DE-10 Board LED Segments
		//max10Board_LEDSegments[0] 
	output reg [9:0] max10Board_LED; //The DE-10 Board LED lights
	input  wire	[1: 0] max10Board_Buttons ;
	input  wire [9:0] max10board_switches;
	
	/////////////////////////////////////////////////////////
	wire systemReset_n = max10Board_Buttons[0]; //active low reset when button0 is held down.


	//reg [19:0] segmentDisplay_DisplayValue ; //Set this to a number and it will display it up to 999999.  
	//	reg [7:0] microphoneInputSample;  //This simulates ADC microphone input.  Updates automatically.

	//--EXAMPLE LIGHTS
	assign max10Board_LED[0] = 1'b1 ; //This turns it on
	assign max10Board_LED[3:1] = max10board_switches[2:0]; //Switch 0 connects to LED 1, switch 1 connects to LED2, switch 2 connects to LED 3.

	assign max10Board_LED[4] = CLK_1hz; //Turn on and off 

	assign segmentDisplay_DisplayValue = (max10board_switches[9] == 0)? 20'd987654 : microphoneInputSample; // If switch is off, use 20'd987654.  If on, use microphoneInputSample

	assign max10Board_LED[9:5] = (microphoneInputSample > 100 && microphoneInputSample < 110 ) ? 5'b10101 : 2'b00; //When sine wave is between 100 and 110, turn them on in specific fashion. 
			//This one assigns 5,6, 7, 8, 9   but if it fails the check, assigns only 2 bits. Quartus will fill in the extra 3 bits with '0'. 





















	/////////////////////////////////////////////////////////
	//Bunch of varoius timed clocks for stuff.  The ClockGenerator module has the equation if you want to make your own clock.
	// 1KHz clock
	wire CLK_1Khz ;
	ClockGenerator clockGenerator_1Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_1Khz)
	);
		defparam	clockGenerator_1Khz.BitsNeeded = 15; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1Khz.InputClockEdgesToCount = 25000;
		
	//  100Hz Clock
	wire CLK_100hz ;
	ClockGenerator clockGenerator_100hz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_100hz)
	);
		defparam	clockGenerator_100hz.BitsNeeded = 25; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_100hz.InputClockEdgesToCount = 250000;
	
	//  10Hz clock
	wire CLK_10hz ;
	ClockGenerator clockGenerator_10hz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_10hz)
	);
		defparam	clockGenerator_10hz.BitsNeeded = 35; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_10hz.InputClockEdgesToCount = 2500000;
	
	//  22050Hz clock
	wire CLK_22Khz ;
	ClockGenerator clockGenerator_22Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_22Khz)
	);
		defparam	clockGenerator_22Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_22Khz.InputClockEdgesToCount = 1133;

	//  32KHz clock
	wire CLK_32Khz ;
	ClockGenerator clockGenerator_32Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_32Khz)
	);
		defparam	clockGenerator_32Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_32Khz.InputClockEdgesToCount = 781; //OLD : 781* 0.975 = 762

	wire CLK_500Khz ;
	ClockGenerator clockGenerator_500Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_500Khz)
	);
		defparam	clockGenerator_500Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_500Khz.InputClockEdgesToCount = 50; //OLD : 781* 0.975 = 762
	
	//  1s clock
	wire CLK_1hz ;
	ClockGenerator clockGenerator_1hz (
		.inputClock(CLK_1Khz),
		.reset_n(systemReset_n),
		.outputClock(CLK_1hz)
	);
		defparam	clockGenerator_1hz.BitsNeeded = 10; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1hz.InputClockEdgesToCount = 500;
	
	//-----------------------
	//--7 Segment Display Control. 
	//-----------------------
	reg [19:0] segmentDisplay_DisplayValue ; //Set this to a number and it will display it up to 999999.  
	SevenSegmentParser sevenSegmentParser(
		.displayValue(segmentDisplay_DisplayValue),
		.segmentPins(max10Board_LEDSegments)
	);
	/////////////////////////////////////////////////////////

	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//------------------------------------
	//---Frequency Generator Sample ------
	//------------------------------------

	reg [7:0] microphoneInputSample;  //This simulates ADC microphone input.  Updates automatically.
	//--Sine
	SignalGenerator signalGenerator_Sine0(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd1), //This is the frequency of the sine wave.   14'd300 = 300Hz , 14'd1000 = 1000Hz.   Limit : 8000Hz
		.outputSample(microphoneInputSample)
	);
	//Not used, kept in case you want to combine multiple SignalGenerators into a single one.  
	//--This is used to apply a amplitude ratio to a signal.  
		// a = sinewave , b = volume    
	function automatic  [7:0] SignalMultiply255 (input [7:0] a, input [7:0] b);
		return  ( (a * b + 127) * 1/255);
	endfunction


endmodule


/*
MISC CODE SNIPPETS
			case(currentState)  //Some binary value here
				5'd0 :  begin
							//--Initial entry state. 
							currentState <= 6'd1;
						end
				//Playback state.  SDRAM is read, DAC uses signals.
				5'd1 :  begin
							if (stateComplete_1 == 2'd1) begin
								currentState <= 6'd12;
							end
							if (stateComplete_1 == 2'd2) begin 
								currentState <= 6'd13;
							end
						end
				5'd12 :  begin
							stateComplete <= 1'b1;
						end
				5'd13 :  begin
							;//stateComplete <= 1'b1;
						end
				default :begin
							currentState <= 6'd12;
						end  
			endcase


		//This makes sure debugString is filled correctly.  
		output logic [31:0] debugString, 
		reg [ 15: 0] counter ;
		assign debugString = {16'b0, counter};


		//Enum example
		enum bit [4:0] { state_DoNothing=5'd0, state_PlaySong0=5'd1, state_PlaySong1=5'd2, state_PlayRecording=5'd3, state_MakeRecording=5'd4, state_EndState=5'd5 } currentState;
		currentState <= state_DoNothing
			currentState is now '0'
		
		Constant
		localparam CMD_UNSELECTED           = 4'b1000; //Device Deselected.  
		assign 4BitVariable = CMD_UNSELECTED


*/