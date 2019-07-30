`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ismael Garcia
// 
// Create Date: 07/29/2019 04:30:41 PM
// Design Name: 
// Module Name: S_AXI_LITE.v
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: AXI LITE Driver
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////
module S_AXI_LITE#(
	parameter integer S_AXI_LITE_SIZE = 5,
	parameter integer S_AXI_DATA_SIZE = 32

)(
	input S_AXI_ACLK,
	input S_AXI_ARESETN,
	//AR
	input  [ 31 : 0] S_AXI_LITE_ARADDR, 
	output S_AXI_LITE_ARREADY,
	input  S_AXI_LITE_ARVALID,
	input  S_AXI_LITE_ARPROT,
	output S_AXI_LITE_RVALID,
	input  S_AXI_LITE_RREADY,
	output [S_AXI_DATA_SIZE - 1: 0] S_AXI_LITE_RDATA ,
	output [1:0] S_AXI_LITE_RRESP,
	//AW
	input  [31 : 0] S_AXI_LITE_AWADDR,
	output S_AXI_LITE_AWREADY,
	input  S_AXI_LITE_AWVALID,
	input  S_AXI_LITE_AWPROT,
	input  S_AXI_LITE_WVALID,
	output S_AXI_LITE_WREADY,
	input  [S_AXI_DATA_SIZE - 1: 0] S_AXI_LITE_WDATA,
	output [1:0] S_AXI_LITE_BRESP,
	output S_AXI_LITE_BVALID,
	input S_AXI_LITE_BREADY
  
);
	reg [S_AXI_DATA_SIZE - 1: 0] axi_reg0;
	reg [S_AXI_DATA_SIZE - 1: 0] axi_reg1;
	reg [S_AXI_DATA_SIZE - 1: 0] axi_reg2 ;
	reg [S_AXI_DATA_SIZE - 1: 0] axi_reg3 ;
	reg [S_AXI_DATA_SIZE - 1: 0] axi_reg4 ;
	
	
	reg [ S_AXI_LITE_SIZE - 1: 0] axi_araddr ;
	reg [ S_AXI_LITE_SIZE - 1: 0] axi_awaddr ;
	
	reg [S_AXI_DATA_SIZE - 1: 0] axi_wdata;
	reg [S_AXI_DATA_SIZE - 1: 0] axi_rdata;

	reg awready;
	reg wready;
	reg awlatch;
	reg bvalid;
    reg wen;
    reg arready;
    reg rvalid;
    
    
 	assign S_AXI_LITE_AWREADY = awready;  
 	assign S_AXI_LITE_WREADY  = wready;
 	assign S_AXI_LITE_BVALID = bvalid;
    assign S_AXI_LITE_ARREADY = arready;
    assign S_AXI_LITE_RVALID = rvalid;
    assign S_AXI_LITE_RDATA = axi_rdata;
    
    //Assert bvalid when BBREADY is available to indicate a successful write.
	always@(posedge S_AXI_ACLK)		
        if(S_AXI_ARESETN == 'b0)
            bvalid <= 0;
        else if(S_AXI_LITE_BREADY && ~bvalid)
            bvalid <= 'b1;
        else
            bvalid <= 'b0;
    
    //Assert awready when AWADDR and WVALID are present.          	
	always@(posedge S_AXI_ACLK)
		if(S_AXI_ARESETN == 'b0)begin
			awready <= 'b0;
		end
		else if(S_AXI_LITE_AWVALID && S_AXI_LITE_WVALID && ~awready)
		begin
			awready <= 'b1;
		end
		else 
			awready <= 'b0;
 		 
		
	//latch write address when awready is asserted. 
	always@(*)
		if(S_AXI_ARESETN == 'b0)
			axi_awaddr <= 0;
		else if (awready)	
		    axi_awaddr <= S_AXI_LITE_AWADDR;
		else 
			axi_awaddr <= axi_awaddr;
			 
	//Assert wready when WVALID is asserted and awready is present.
	always@(posedge S_AXI_ACLK)		
		if(S_AXI_ARESETN == 'b0)begin
 			wready <= 0;
		end
		else if(S_AXI_LITE_WVALID && ~wready && awready)
			wready <= 'b1;
		else  
			wready <= 'b0;		
		 
    //latch data when wready is asserted.
	always@(*)
        if(S_AXI_ARESETN == 'b0) begin
			axi_wdata <= 0;
		end else if (wready) begin	
		    axi_wdata <= S_AXI_LITE_WDATA;
		end else begin
			axi_wdata <= axi_wdata;
			end
			
	//Write into registers when a valid address and valid data is present.  
 	always@(*)
        if(S_AXI_ARESETN == 'b0)
            begin
               axi_reg0 <= 0;
               axi_reg1 <= 0;
               axi_reg2 <= 0;
               axi_reg3 <= 0;
               axi_reg4 <= 0;
            end
         else begin case(axi_awaddr[ S_AXI_LITE_SIZE - 1 :0])
            5'b00000: 
             begin
               if(wready)
                   axi_reg0 <= axi_wdata;
               end
            5'b00100:begin
               if(wready)
                   axi_reg1 <= axi_wdata;
               end    
            5'b01000:begin
               if(wready)
                   axi_reg2 <= axi_wdata;
               end
            5'b01100:begin
               if(wready)
                   axi_reg3 <= axi_wdata;
               end
            5'b10000:begin        
               if(wready)
                   axi_reg4 <= axi_wdata;
               end
           endcase
           end
           
    //Assert arready when ARVALID is asserted, indicating a valid address to read.          			
    always@(posedge  S_AXI_ACLK)
        if(S_AXI_ARESETN == 'b0) 
            arready <= 'b0;
        else if(S_AXI_LITE_ARVALID && ~arready)
            arready <= 'b1;
        else
            arready <= 'b0;
     //Latch ARADDR to axi_aradddr register
     always@(*)
        if(S_AXI_ARESETN == 'b0) 
            axi_araddr <= 0;
        else if(arready)
            axi_araddr <= S_AXI_LITE_ARADDR;
        else
            axi_araddr <= axi_araddr;
        
    //Assert rvalid when RREADY and arready are asserted.
    always@(posedge  S_AXI_ACLK)
        if(S_AXI_ARESETN == 'b0) 
           rvalid <= 'b0;
        else if(arready && S_AXI_LITE_RREADY && ~rvalid)
            rvalid <= 'b1;
        else
            rvalid <= 'b0;    
        
    //read from registers
    always@(*)
    if(S_AXI_ARESETN == 'b0) 
        axi_rdata <= 'b0;
    else begin case(axi_araddr[ S_AXI_LITE_SIZE - 1 :0])
    5'b00000: begin
              if(rvalid)
              axi_rdata <= axi_reg0; 
              end
    5'b00100: begin
              if(rvalid)
              axi_rdata <= axi_reg1; 
              end
    5'b01000: begin
              if(rvalid)
              axi_rdata <= axi_reg2; 
              end
    5'b01100: begin
              if(rvalid)
              axi_rdata <= axi_reg3; 
              end                                 
    5'b10000: begin
              if(rvalid)
              axi_rdata <= axi_reg4; 
              end                                 
    endcase
    end                    
                                  
                                   
 
	
endmodule