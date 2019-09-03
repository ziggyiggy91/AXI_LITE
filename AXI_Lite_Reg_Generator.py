import math
# AXI LITE GENERATOR
#About: AXI_Lite_Reg_Generator.py program is used to generate x amount of registers.
#Engineer: Ismael Garcia
#Data: 7/30/19


#EX:
#   Enter module name for verilog
#       input <= axi_test.v
#
#   module axi_test#(......
#
#   Enter registers for AXI
#       inputReg <= 100
#       
#   integer parameter S_AXI_LITE_SIZE = 9
axi_size = 0

def main():
    val0 = input("Enter module name for verilog ")
    f = open(val0,"w+")
    val1 = val0.split('.')
    f.write("module " + val1[0] + "#")
    regData = input("Enter registers for AXI ")
    ipParameters(f,regData)
    inputParameters(f)
    createRegisters(f,regData)
    axiSignals(f,regData)
    f.close()

def ipParameters(file,regData):
    global axi_size
    axi_size = math.ceil(math.log(int(regData) * 4,2))
    file.write("(\n\t\tparameter integer S_AXI_LITE_SIZE = " + str(axi_size) + ",\n")
    file.write("\t\tparameter integer S_AXI_DATA_SIZE = 32 \n\t\t)")
 
               
    
def inputParameters(file):
    file.write("(\n\t\tinput S_AXI_ACLK,\n\
	\tinput S_AXI_ARESETN,\n\
        //AR\n\
        input  [ 31 : 0] S_AXI_LITE_ARADDR,\n\
        output S_AXI_LITE_ARREADY,\n\
        input  S_AXI_LITE_ARVALID,\n\
        //input  S_AXI_LITE_ARPROT,\n\
        output S_AXI_LITE_RVALID,\n\
        input  S_AXI_LITE_RREADY,\n\
        output [S_AXI_DATA_SIZE - 1: 0] S_AXI_LITE_RDATA,\n\
        //output [1:0] S_AXI_LITE_RRESP,\n\
        //AW\n\
        input  [ 31 : 0] S_AXI_LITE_AWADDR,\n\
        output S_AXI_LITE_AWREADY,\n\
        input  S_AXI_LITE_AWVALID,\n\
        //input  S_AXI_LITE_AWPROT,\n\
        input  S_AXI_LITE_WVALID,\n\
        output S_AXI_LITE_WREADY,\n\
        input  [S_AXI_DATA_SIZE - 1: 0] S_AXI_LITE_WDATA,\n\
        //output [1:0] S_AXI_LITE_BRESP,\n\
        output S_AXI_LITE_BVALID,\n\
        input S_AXI_LITE_BREADY\n\t\t);\n\n\n")
    
   
def createRegisters(file,regData):
    file.write("\t\t//AXI LITE Register instantiation\n")   
    for x in range(int(regData)):
        file.write("\t\treg [S_AXI_DATA_SIZE - 1: 0] axi_reg" + str(x) +";\n")

  
    file.write("\t\t\n\
        reg [ 31 : 0] axi_araddr ;\n\
        reg [ 31 : 0] axi_awaddr ;\n\n\
        reg [S_AXI_DATA_SIZE - 1: 0] axi_wdata;\n\
        reg [S_AXI_DATA_SIZE - 1: 0] axi_rdata;\n\n\
        reg awready;\n\
        reg wready;\n\
        reg awlatch;\n\
        reg bvalid;\n\
        reg axi_wen;\n\
        reg axi_wack;\n\
        reg arready;\n\
        reg rvalid;\n\
        reg axi_rvalid;\n\n\
        assign S_AXI_LITE_AWREADY = awready;\n\
        assign S_AXI_LITE_WREADY  = wready;\n\
        assign S_AXI_LITE_BVALID = bvalid;\n\
        assign S_AXI_LITE_ARREADY = arready;\n\
        assign S_AXI_LITE_RVALID = axi_rvalid;\n\
        assign S_AXI_LITE_RDATA = axi_rdata;\n\n")

def axiSignals(file,regData):
    global axi_size
    #BVALID
    file.write("\t\t//Assert bvalid when BBREADY is available to indicate a successful write.\n\
        always@(posedge S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0)\n\
            bvalid <= 0;\n\
          else if(S_AXI_LITE_BREADY && ~bvalid)\n\
            bvalid <= 'b1;\n\
          else\n\
            bvalid <= 'b0;\n\n\n")

    #AWREADY
    file.write("\t\t//Assert awready when AWADDR and WVALID are present.\n\
        always@(posedge S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0)\n\
            awready <= 'b0;\n\
          else if(S_AXI_LITE_AWVALID && S_AXI_LITE_WVALID && ~awready)\n\
            awready <= 'b1;\n\
          else if(wready)\n\
            awready <= 'b0;\n\
          else\n\
            awready <= awready;\n\n\n")
 
    #AWADDR
    file.write("\t\t//latch write address when awready is asserted.\n\
        always@(posedge S_AXI_ACLK)\n\
            if(S_AXI_ARESETN == 'b0)\n\
                axi_awaddr <= 0;\n\
            else if (awready)\n\
                axi_awaddr <= S_AXI_LITE_AWADDR;\n\
            else\n\
                axi_awaddr <= axi_awaddr;\n\n\n")
    #WREADY
    file.write("\t\t//Assert wready when WVALID is asserted and awready is present.\n\
        always@(posedge S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0)\n\
            wready <= 0;\n\
          else if(S_AXI_LITE_WVALID && ~wready && awready)\n\
            wready <= 'b1;\n\
          else\n\
            wready <= 'b0;\n\n\n")
    
    #WDATA
    file.write("\t\t//latch data when wready is asserted.\n\
        always@(posedge S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0) begin\n\
            axi_wdata <= 0;\n\
            axi_wen <= 0;\n\
          end else if(awready && wready) begin\n\
            axi_wdata <= S_AXI_LITE_WDATA;\n\
            axi_wen <= 'b1;\n\
          end else if(axi_wen)\n\
            axi_wen <= 'b0;\n\
          else begin\n\
            axi_wdata <= axi_wdata;\n\
            axi_wen <= axi_wen;\n\
          end\n\n\n")
	 
    #STORE REGISTERS
    file.write("\t\t//Write into registers when a valid address and valid data is present.\n\
        always@(posedge S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0)begin\n")
    
    for x in range(int(regData)):
      file.write("\t\t    axi_reg" + str(x) +" <= 0;\n")
    
    for x in range(int(regData)):
       file.write("\t\t  end else if (axi_awaddr[ S_AXI_LITE_SIZE - 1 :0] == " + str(axi_size) + "'d" + str(x*4) + ")begin\n\
            if(axi_wen) begin\n\
             axi_reg" + str(x) + "<= axi_wdata;\n\
             axi_wack <= 'b1;\n\
            end else begin\n\
             axi_reg" + str(x) + "<= axi_reg" + str(x) + ";\n\
             axi_wack <= 'b0;\n\
            end\n")
    file.write("\t\t  end\n\n\n")
  

    #ARREADY
    file.write("\t\t//Assert arready when ARVALID is asserted, indicating a valid address to read.\n\
        always@(posedge  S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0)\n\
            arready <= 'b0;\n\
          else if(S_AXI_LITE_ARVALID && ~arready)\n\
            arready <= 'b1;\n\
          else\n\
            arready <= 'b0;\n\n\n")

    
    #ARADDR
    file.write("\t\t//Latch ARADDR to axi_aradddr register\n\
        always@(posedge S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0)\n\
            axi_araddr <= 0;\n\
          else if(arready)\n\
            axi_araddr <= S_AXI_LITE_ARADDR;\n\
          else\n\
            axi_araddr <= axi_araddr;\n\n\n")

    
    #RVALID
    file.write("\t\t//Assert rvalid when RREADY and arready are asserted.\n\
        always@(posedge  S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0)\n\
            rvalid <= 'b0;\n\
          else if(arready && S_AXI_LITE_RREADY && ~rvalid)\n\
            rvalid <= 'b1;\n\
          else\n\
            rvalid <= 'b0;\n\n\n")
    
    #READ REGISTERS
    file.write("\t\t//read from registers\n\
        always@(posedge S_AXI_ACLK)\n\
          if(S_AXI_ARESETN == 'b0)begin\n\
            axi_rvalid <= 'b0;\n\
            axi_rdata <= 'b0;\n")
 
				
    for x in range(int(regData)):
      file.write("\t\t  end else if(axi_araddr[ S_AXI_LITE_SIZE - 1 :0] == " + str(axi_size) + "'d" + str(x*4) + ")begin\n\
            if(rvalid)begin\n\
              axi_rdata <= axi_reg" + str(x) + ";\n\
              axi_rvalid <= 'b1;\n\
            end else begin\n\
              axi_rvalid <= 'b0;\n\
              axi_rdata <= axi_rdata;\n\
            end\n")
		
    file.write("\t\t\tend else begin\n\
              axi_rvalid <= 'b0;\n\
              axi_rdata <= axi_rdata;\n\
            end\n")
 

    file.write("endmodule\n")
               
main()
