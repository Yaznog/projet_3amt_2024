//========================================================================================
//
//   Copyright (C) 2018
//   Dynamixel Package controller Top-level
//   Author: Sylvain ENGELS
//
//========================================================================================
//  This source file may be used and distributed without restriction provided that this
//  copyright statement is not removed from the file and that any derivative work contains
//  the original copyright notice and the associated disclaimer.
//----------------------------------------------------------------------------------------
//  THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
//  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
//  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//========================================================================================
`ifndef UGA_DYNA_PKG
`define UGA_DYNA_PKG
   package uga_dyna_pkg;

     //---------------------------------------------------------------------------------------------
     // Dynamixel Instruction
     //---------------------------------------------------------------------------------------------
     typedef enum logic [7:0] {
         PING        = 8'h01, // No execution. It is used when controller is ready to receive Status Packet
         READ_DATA   = 8'h02, // This command reads data from Dynamixel
         WRITE_DATA  = 8'h03, // This command writes data to Dynamixel 2 or more
         REG_WRITE   = 8'h04, // It is similar to WRITE_DATA, but it remains in the standby state without being executed until the ACTION command arrives.
         ACTION      = 8'h05, // This command initiates motions registered with REG WRITE
         RESET       = 8'h06, // This command restores the state of Dynamixel to the factory default setting.
         REBOOT      = 8'h08, // This command reboots Dynamixel.
         SYNC_WRITE  = 8'h83, // This command is used to control several Dynamixels simultaneously at a time.
         BULK_READ   = 8'h92  // This command write data on diff. addresses with diff. length at once (only in MX series).
     } instruction_t;

     //---------------------------------------------------------------------------------------------
     // Instruction Packet
     //---------------------------------------------------------------------------------------------
     typedef struct packed {
       logic   [1:0][7:0] preamble;    // This signal notifies the beginning of the packet (must be 16'hFF_FF)
       logic        [7:0] id;          // It is the ID of Dynamixel which will receive Instruction Packet
       logic        [7:0] length;      // It is the length of the packet. The length is calculated as "the number of Parameters (N) + 2".
       instruction_t      inst;        // 8-bit instruction, enumerated type
       logic   [0:5][7:0] param ;      // Parameter is used when Instruction requires additionnal data (--> Max parameter is 6)
       logic        [7:0] checksum;    // Used to check if packet is damaged during communication
     } instruction_packet_t;

     //---------------------------------------------------------------------------------------------
     // Status Packet
     //---------------------------------------------------------------------------------------------
     typedef struct packed {
       logic  unused;           // Unused (Reserved for  future ude)
       logic  instruction;      // In case of sending an undefined instruction or delivering the action instruction without the reg_write instruction, it is set as 1
       logic  overload;         // When the current load cannot be controlled by the set Torque, it is set as 1
       logic  checksum;         // When the Checksum of the transmitted Instruction Packet is incorrect, it is set as 1
       logic  range;            // When an instruction is out of the range for use, it is set as 1
       logic  overheating;      // When internal temperature of Dynamixel is out of the range of operating temperature set in the Control table, it is set as 1
       logic  angle;            // When Goal Position is written out of the range from CW Angle Limit to CCW Angle Limit , it is set as 1
       logic  voltage;          // When the applied voltage is out of the range of operating voltage set in the Control table, it is as 1
     } error_byte_t;

     typedef struct packed {
       logic [1:0][7:0] preamble;    // This signal notifies the beginning of the packet (must be 16'hFF_FF)
       logic      [7:0] id;          // It is the ID of Dynamixel which will receive Instruction Packet
       logic      [7:0] length;      // It is the length of the packet. The length is calculated as "the number of Parameters (N) + 2".
       error_byte_t     error;       // 8-bit error register
       logic [0:3][7:0] param ;      // Parameter is used when Instruction requires additionnal data (--> Max parameter is 4)
       logic      [7:0] checksum;    // Used to check if packet is damaged during communication
     } status_packet_t;

     //---------------------------------------------------------------------------------------------
     // Checksum Computing
     // Used to check if packet is damaged during communication. 
     // Check Sum is calculated according to the following formula.
     //    Check Sum = ~ ( ID + Length + Instruction + Parameter1 + ? Parameter N )
     //---------------------------------------------------------------------------------------------
     function [7:0] dyna_inst_checksum (input instruction_packet_t pkt);
       logic [7:0] checksum_tmp;
       integer i;
       begin
         checksum_tmp = pkt.id + pkt.length + pkt.inst;
         // Only 6 parameters are supported for time being (in future, shoud be replaced by (pkt.length-2))
         // We can go to max parameter as default value is 'h00
         for (i=0 ; i<6 ; i++) checksum_tmp = checksum_tmp + pkt.param[i];
         return ~checksum_tmp;
       end
     endfunction
     
     function [7:0] dyna_status_checksum (input status_packet_t pkt);
       logic [7:0] checksum_tmp;
       integer i;
       begin
         checksum_tmp = pkt.id + pkt.length + pkt.error;
         // Only 6 parameters are supported for time being (in future, shoud be replaced by (pkt.length-2))
         // We can go to max parameter as default value is 'h00
         for (i=0 ; i<4 ; i++) checksum_tmp = checksum_tmp + pkt.param[i];
         return ~checksum_tmp;
       end
     endfunction


// EEPROM Area Code
//Address Size(Byte) Data Name             Description                     Access   InitialValue
// 0   0x00   2          Model Number          Model Number                     R       29
// 2   0x02   1          Firmware Version      Firmware Version                 R       -
// 3   0x03   1          ID                    DYNAMIXEL ID                     RW      1
// 4   0x04   1          Baud Rate             Communication Speed              RW      34
// 5   0x05   1          Return Delay Time     Response Delay Time              RW      250
// 6   0x06   2          CW Angle Limit        Clockwise Angle Limit            RW      0
// 8   0x08   2          CCW Angle Limit       Counter-Clockwise Angle Limit    RW      4,095
// 11  0x0B   1          Temperature Limit     Maximum Int. Temperature Limit   RW      80
// 12  0x0C   1          Min Voltage Limit     Minimum Input Voltage Limit      RW      60
// 13  0x0D   1          Max Voltage Limit     Maximum Input Voltage Limit      RW      160
// 14  0x0E   2          Max Torque            Maximun Torque                   RW      1023
// 16  0x10   1          Status Return Level   Select Types of Status Return    RW      2
// 17  0x11   1          Alarm LED             LED for Alarm                    RW      36
// 18  0x12   1          Shutdown              Shutdown Error Information       RW      36
// 20  0x14   2          Multi Turn Offset     Adjust Position with Offset      RW      0
// 22  0x16   1          Resolution Divider    Divider for Position Resolution  RW      1

// RAM Area Code

//Address Size(Byte) Data Name             Description                      Access  InitialValue
// 24  0x18   1          Torque Enable         Motor Torque On/Off              RW      0
// 25  0x19   1          LED                   Status LED On/Off                RW      0
// 26  0x1A   1          D Gain                Derivative Gain                  RW      0
// 27  0x1B   1          I Gain                Integral Gain                    RW      0
// 28  0x1C   1          P Gain                Proportional Gain                RW      32
// 30  0x1E   2          Goal Position         Desired Position                 RW      -
// 32  0x20   2          Moving Speed          Moving Speed(Moving Velocity)    RW      -
// 34  0x22   2          Torque Limit          Torque Limit(Goal Torque)        RW      ADD 14&15
// 36  0x24   2          Present Position      Present Position                 R       -
// 38  0x26   2          Present Speed         Present Speed                    R       -
// 40  0x28   2          Present Load          Present Load                     R       -
// 42  0x2A   1          Present Voltage       Present Voltage                  R       -
// 43  0x2B   1          Present Temperature   Present Temperature              R       -
// 44  0x2C   1          Registered            If Instruction is registered     R       0
// 46  0x2E   1          Moving                Movement Status                  R       0
// 47  0x2F   1          Lock                  Locking EEPROM                   RW      0
// 48  0x30   2          Punch                 Minimum Current Threshold        RW      0
// 50  0x32   2          Realtime Tick         Count Time in millisecond        R       0
// 73  0x49   1          Goal Acceleration     Goal Acceleration                RW      0


   endpackage
`endif // UGA_DYNA_PKG
