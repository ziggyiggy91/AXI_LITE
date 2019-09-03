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
        //input  S_AXI_LITE_ARPROT,
        output S_AXI_LITE_RVALID,
        input  S_AXI_LITE_RREADY,
        output [S_AXI_DATA_SIZE - 1: 0] S_AXI_LITE_RDATA,
        //output [1:0] S_AXI_LITE_RRESP,
        //AW
        input  [ 31 : 0] S_AXI_LITE_AWADDR,
        output S_AXI_LITE_AWREADY,
        input  S_AXI_LITE_AWVALID,
        //input  S_AXI_LITE_AWPROT,
        input  S_AXI_LITE_WVALID,
        output S_AXI_LITE_WREADY,
        input  [S_AXI_DATA_SIZE - 1: 0] S_AXI_LITE_WDATA,
        //output [1:0] S_AXI_LITE_BRESP,
        output S_AXI_LITE_BVALID,
        input S_AXI_LITE_BREADY
		);


		//AXI LITE Register instantiation
		reg [S_AXI_DATA_SIZE - 1: 0] axi_reg0;
		reg [S_AXI_DATA_SIZE - 1: 0] axi_reg1;
		reg [S_AXI_DATA_SIZE - 1: 0] axi_reg2;
		reg [S_AXI_DATA_SIZE - 1: 0] axi_reg3;
		reg [S_AXI_DATA_SIZE - 1: 0] axi_reg4;
		reg [S_AXI_DATA_SIZE - 1: 0] axi_reg5;
		
        reg [ 31 : 0] axi_araddr ;
        reg [ 31 : 0] axi_awaddr ;

        reg [S_AXI_DATA_SIZE - 1: 0] axi_wdata;
        reg [S_AXI_DATA_SIZE - 1: 0] axi_rdata;

        reg awready;
        reg wready;
        reg awlatch;
        reg bvalid;
        reg axi_wen;
        reg axi_wack;
        reg arready;
        reg rvalid;
        reg axi_rvalid;

        assign S_AXI_LITE_AWREADY = awready;
        assign S_AXI_LITE_WREADY  = wready;
        assign S_AXI_LITE_BVALID = bvalid;
        assign S_AXI_LITE_ARREADY = arready;
        assign S_AXI_LITE_RVALID = axi_rvalid;
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
          if(S_AXI_ARESETN == 'b0)
            awready <= 'b0;
          else if(S_AXI_LITE_AWVALID && S_AXI_LITE_WVALID && ~awready)
            awready <= 'b1;
          else if(wready)
            awready <= 'b0;
          else
            awready <= awready;


		//latch write address when awready is asserted.
        always@(posedge S_AXI_ACLK)
            if(S_AXI_ARESETN == 'b0)
                axi_awaddr <= 0;
            else if (awready)
                axi_awaddr <= S_AXI_LITE_AWADDR;
            else
                axi_awaddr <= axi_awaddr;


		//Assert wready when WVALID is asserted and awready is present.
        always@(posedge S_AXI_ACLK)
          if(S_AXI_ARESETN == 'b0)
            wready <= 0;
          else if(S_AXI_LITE_WVALID && ~wready && awready)
            wready <= 'b1;
          else
            wready <= 'b0;


		//latch data when wready is asserted.
        always@(posedge S_AXI_ACLK)
          if(S_AXI_ARESETN == 'b0) begin
            axi_wdata <= 0;
            axi_wen <= 0;
          end else if(awready && wready) begin
            axi_wdata <= S_AXI_LITE_WDATA;
            axi_wen <= 'b1;
          end else if(axi_wen)
            axi_wen <= 'b0;
          else begin
            axi_wdata <= axi_wdata;
            axi_wen <= axi_wen;
          end


		//Write into registers when a valid address and valid data is present.
        always@(posedge S_AXI_ACLK)
          if(S_AXI_ARESETN == 'b0)begin
		    axi_reg0 <= 0;
		    axi_reg1 <= 0;
		    axi_reg2 <= 0;
		    axi_reg3 <= 0;
		    axi_reg4 <= 0;
		    axi_reg5 <= 0;
		  end else if (axi_awaddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd0)begin
            if(axi_wen) begin
             axi_reg0<= axi_wdata;
             axi_wack <= 'b1;
            end else begin
             axi_reg0<= axi_reg0;
             axi_wack <= 'b0;
            end
		  end else if (axi_awaddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd4)begin
            if(axi_wen) begin
             axi_reg1<= axi_wdata;
             axi_wack <= 'b1;
            end else begin
             axi_reg1<= axi_reg1;
             axi_wack <= 'b0;
            end
		  end else if (axi_awaddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd8)begin
            if(axi_wen) begin
             axi_reg2<= axi_wdata;
             axi_wack <= 'b1;
            end else begin
             axi_reg2<= axi_reg2;
             axi_wack <= 'b0;
            end
		  end else if (axi_awaddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd12)begin
            if(axi_wen) begin
             axi_reg3<= axi_wdata;
             axi_wack <= 'b1;
            end else begin
             axi_reg3<= axi_reg3;
             axi_wack <= 'b0;
            end
		  end else if (axi_awaddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd16)begin
            if(axi_wen) begin
             axi_reg4<= axi_wdata;
             axi_wack <= 'b1;
            end else begin
             axi_reg4<= axi_reg4;
             axi_wack <= 'b0;
            end
		  end else if (axi_awaddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd20)begin
            if(axi_wen) begin
             axi_reg5<= axi_wdata;
             axi_wack <= 'b1;
            end else begin
             axi_reg5<= axi_reg5;
             axi_wack <= 'b0;
            end
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
        always@(posedge S_AXI_ACLK)
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
        always@(posedge S_AXI_ACLK)
          if(S_AXI_ARESETN == 'b0)begin
            axi_rvalid <= 'b0;
            axi_rdata <= 'b0;
		  end else if(axi_araddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd0)begin
            if(rvalid)begin
              axi_rdata <= axi_reg0;
              axi_rvalid <= 'b1;
            end else begin
              axi_rvalid <= 'b0;
              axi_rdata <= axi_rdata;
            end
		  end else if(axi_araddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd4)begin
            if(rvalid)begin
              axi_rdata <= axi_reg1;
              axi_rvalid <= 'b1;
            end else begin
              axi_rvalid <= 'b0;
              axi_rdata <= axi_rdata;
            end
		  end else if(axi_araddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd8)begin
            if(rvalid)begin
              axi_rdata <= axi_reg2;
              axi_rvalid <= 'b1;
            end else begin
              axi_rvalid <= 'b0;
              axi_rdata <= axi_rdata;
            end
		  end else if(axi_araddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd12)begin
            if(rvalid)begin
              axi_rdata <= axi_reg3;
              axi_rvalid <= 'b1;
            end else begin
              axi_rvalid <= 'b0;
              axi_rdata <= axi_rdata;
            end
		  end else if(axi_araddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd16)begin
            if(rvalid)begin
              axi_rdata <= axi_reg4;
              axi_rvalid <= 'b1;
            end else begin
              axi_rvalid <= 'b0;
              axi_rdata <= axi_rdata;
            end
		  end else if(axi_araddr[ S_AXI_LITE_SIZE - 1 :0] == 5'd20)begin
            if(rvalid)begin
              axi_rdata <= axi_reg5;
              axi_rvalid <= 'b1;
            end else begin
              axi_rvalid <= 'b0;
              axi_rdata <= axi_rdata;
            end
			end else begin
              axi_rvalid <= 'b0;
              axi_rdata <= axi_rdata;
            end
endmodule
