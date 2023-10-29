with System.CRC32;
with Interfaces;

package Min_Ada is

   type Bit     is mod 2**1     with Size => 1;
   type Byte    is mod 2**8     with Size => 8;
   type UInt4   is mod 2**4     with Size => 4;
   type UInt32  is mod 2**32    with Size => 32;

   MAX_PAYLOAD          : constant Byte := 255;

   HEADER_BYTE          : constant Byte := 16#AA#;
   STUFF_BYTE           : constant Byte := 16#55#;
   EOF_BYTE             : constant Byte := 16#55#;

   SEARCHING_FOR_SOF    : constant UInt4 := 0;
   RECEIVING_ID_CONTROL : constant UInt4 := 1;
   RECEIVING_SEQ        : constant UInt4 := 2;
   RECEIVING_LENGTH     : constant UInt4 := 3;
   RECEIVING_PAYLOAD    : constant UInt4 := 4;
   RECEIVING_CHECKSUM_3 : constant UInt4 := 5;
   RECEIVING_CHECKSUM_2 : constant UInt4 := 6;
   RECEIVING_CHECKSUM_1 : constant UInt4 := 7;
   RECEIVING_CHECKSUM_0 : constant UInt4 := 8;
   RECEIVING_EOF        : constant UInt4 := 9;

   type App_ID is mod 2**6
      with Size => 6;

   type Frame_Header is record
      Header_0      : Byte;
      Header_1      : Byte;
      Header_2      : Byte;
      ID            : App_ID;
      Reserved      : Bit;
      Transport     : Bit;
   end record with Size => 32;
   pragma Pack (Frame_Header);

   type Min_Payload is array (0 .. MAX_PAYLOAD) of Byte;

   type CRC_Bytes is record
      CRC_0 : Byte;
      CRC_1 : Byte;
      CRC_2 : Byte;
      CRC_3 : Byte;
   end record with Size => 32;
   pragma Pack (CRC_Bytes);

   type CRC_Bytes_Arr is array (1 .. 4) of Byte;

   type Min_Context is record
      Rx_Frame_Payload_Buffer   : Min_Payload;
         --  Payload received so far

      Rx_Frame_Checksum         : CRC_Bytes;
         --  Checksum received over the wire

      Rx_Checksum               : System.CRC32.CRC32;
         --  Calculated checksum for receiving frame

      Tx_Checksum               : System.CRC32.CRC32;
         --  Calculated checksum for sending frame

      Rx_Header_Bytes_Seen      : Byte;
         --  Countdown of header bytes to reset state

      Rx_Frame_State            : UInt4;
         --  State of receiver

      Rx_Frame_Payload_Bytes    : Byte;
         --  Length of payload received so far

      Rx_Frame_ID_Control       : Byte;
         --  ID and control bit of frame being received

      Rx_Frame_Seq              : Byte;
         --  Sequence number of frame being received

      Rx_Frame_Length           : Byte;
         --  Length of frame

      Rx_Control                : Byte;
         --  Control byte

      Tx_Header_Byte_Countdown  : Byte;
         --  Count out the header bytes

      Port                      : Byte;
         --  Number of the port associated with the context
   end record;

   procedure Send_Frame (
      Context           : in out Min_Context;
      ID                : App_ID;
      Payload           : Min_Payload;
      Payload_Length    : Byte
   );

   procedure Rx_Bytes (
      Context   : in out Min_Context;
      Data      : Byte
   );

   procedure Tx_Byte (
      Data  : Byte
   );

   procedure Stuffed_Tx_Byte (
      Context   : in out Min_Context;
      Data      : Byte;
      CRC       : Boolean
   );

   procedure Min_Init_Context (
      Context : in out Min_Context
   );

end Min_Ada;
