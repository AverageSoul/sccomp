// data memory
module dm(clk, DMWr, addr, din, memOp, EXTOp, dout);
   input          clk;
   input          DMWr;
   input  [8:0]   addr;
   input  [31:0]  din;
   input  [1:0]   memOp;
   input          EXTOp;
   output [31:0]  dout;
     
   reg [31:0] dmem[127:0];
   reg [31:0] dout_tmp;


   integer i;
   initial begin
   for (i = 0; i < 128; i = i + 1) begin
        dmem[i] = 32'b0;
    end
   end
   always @(posedge clk) begin
      if (DMWr) begin
         case (memOp)
            2'b00: begin  // 字操作
               dmem[addr[8:2]] <= din;  // 存储32位
            end
            2'b10: begin  // 字节操作
                case (addr[1:0])
                    2'b00: dmem[addr[8:2]][7:0] = din[7:0];  // 最低字节
                    2'b01: dmem[addr[8:2]][15:8] = din[7:0];  // 低字节
                    2'b10: dmem[addr[8:2]][23:16] = din[7:0]; // 中字节
                    2'b11: dmem[addr[8:2]][31:24] = din[7:0];  // 高字节
                endcase
            end
            2'b01: begin  // 半字操作
               if (addr[1] == 1'b0) begin
                  dmem[addr[8:2]][15:0] = din[15:0];  // 存储低16位
               end 
               else begin
                  dmem[addr[8:2]][31:16] = din[15:0]; // 存储高16位
               end
            end

         endcase
       $display("Write: Addr = 0x%2h, Data = 0x%8h", addr[8:2], dmem[addr[8:2]]);
      end
  end

  always @(*) begin
    case (memOp)
    2'b00: begin
      dout_tmp <= dmem[addr[8:2]];
    end

    2'b01: begin
      case (addr[1])
        1'b0: begin
          if (EXTOp)
            dout_tmp = {{16{dmem[addr[8:2]][15]}},dmem[addr[8:2]][15:0]};
          else
            dout_tmp = {{16{0}},dmem[addr[8:2]][15:0]};
        end 
        1'b1: begin
          if (EXTOp)
            dout_tmp = {{16{dmem[addr[8:2]][31]}},dmem[addr[8:2]][31:16]};
          else
            dout_tmp = {{16{0}},dmem[addr[8:2]][31:16]};
        end
      endcase
    end

    2'b10: begin
      case (addr[1:0])
        2'b00: begin
          if (EXTOp)
            dout_tmp = {{24{dmem[addr[8:2]][7]}},dmem[addr[8:2]][7:0]};
          else
            dout_tmp = {{24{0}},dmem[addr[8:2]][7:0]};
        end
        2'b01: begin
          if (EXTOp)
            dout_tmp = {{24{dmem[addr[8:2]][15]}},dmem[addr[8:2]][15:8]};
          else
            dout_tmp = {{24{0}},dmem[addr[8:2]][15:8]};
        end
        2'b10: begin
          if (EXTOp)
            dout_tmp = {{24{dmem[addr[8:2]][23]}},dmem[addr[8:2]][23:16]};
          else
            dout_tmp = {{24{0}},dmem[addr[8:2]][23:16]};
        end
        2'b11: begin
          if (EXTOp)
            dout_tmp = {{24{dmem[addr[8:2]][31]}},dmem[addr[8:2]][31:24]};
          else
            dout_tmp = {{24{0}},dmem[addr[8:2]][31:24]};
        end
      endcase
      end
    endcase
    $display("Read: Addr = 0x%2h, Data = 0x%8h", addr[8:2], dout_tmp);
  end


  assign dout = dout_tmp;

  // $display("dmem[%2d] = 0x%8X,", addr, dmem[addr]);

endmodule    
