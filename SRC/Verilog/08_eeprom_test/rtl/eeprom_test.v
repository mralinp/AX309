`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    eeprom_test 
// Function: write and read eeprom using I2C bus
//////////////////////////////////////////////////////////////////////////////////
module eeprom_test
(
    input CLK_50M,
	 input RSTn,
	 output [3:0]LED,
	 
	 output SCL,          //EEPROM IIC clock
	 inout SDA            //EEPROM IIC data
);
  
  
wire [7:0] RdData;       //EEPROM �������ݼĴ���
wire Done_Sig;           //IICͨ������ź�

reg [3:0] i;
reg [3:0] rLED;

reg [7:0] rAddr;
reg [7:0] rData;
reg [1:0] isStart;

assign LED = rLED;

/***************************/
/*   EEPROM write and read */
/***************************/	  
always @ ( posedge CLK_50M or negedge RSTn )	
	 if( !RSTn ) begin
			i <= 4'd0;
			rAddr <= 8'd0;
			rData <= 8'd0;
			isStart <= 2'b00;
         rLED <= 4'b0000;
	 end
	 else
		case( i )
				
	     0:
		  if( Done_Sig ) begin isStart <= 2'b00; i <= i + 1'b1; end                    //�ȴ�IICд�������, ���i״̬��Ϊ1
		  else begin isStart <= 2'b01; rData <= 8'h12; rAddr <= 8'd0; end              //eeprom д����(0x12)��addr 0
					 
		  1:
		  if( Done_Sig ) begin isStart <= 2'b00; i <= i + 1'b1; end                    //�ȴ�IIC���������, ���i״̬��Ϊ2
		  else begin isStart <= 2'b10; rAddr <= 8'd0; end                              //eeprom �� addr 0������
					 
		  2:
		  begin rLED <= RdData[3:0]; end		                 //led�Ƹ�ֵ 
		
		endcase	
	 
/***************************/
//I2Cͨ�ų���//
/***************************/				
iic_com U1
	 (
	     .CLK( CLK_50M ),
		  .RSTn( RSTn ),
		  .Start_Sig( isStart ),                //iic��д����: 2'b01ΪIICд; 2'b10ΪIIC��
		  .Addr_Sig( rAddr ),                   //EEPROM��iic��д��ַ
		  .WrData( rData ),                     //EEPROM��iicд����
		  .RdData( RdData ),                    //EEPROM��iic������
		  .Done_Sig( Done_Sig ),                //IIC��д����ź�,��IIC��д�������
	     .SCL( SCL ),
		  .SDA( SDA )
);

/***************************/
//chipscope icon��ila, ���ڹ۲��ź�//
/***************************/	
wire [35:0]   CONTROL0;
wire [255:0]  TRIG0;
chipscope_icon icon_debug (
    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
);

chipscope_ila ila_filter_debug (
    .CONTROL(CONTROL0), // INOUT BUS [35:0]
   // .CLK(dma_clk),    // IN
    .CLK(CLK_50M),      // IN, chipscope�Ĳ���ʱ��
    .TRIG0(TRIG0)       // IN BUS [255:0], �������ź�
    //.TRIG_OUT(TRIG_OUT0)
);                                                     

assign  TRIG0[7:0]=RdData;    //����RdData�ź�                                           


endmodule