package Min_Ada is

   type Bit     is mod 2**1     with Size => 1;
   type Byte    is mod 2**8     with Size => 8;
   type UInt4   is mod 2**4     with Size => 4;
   type UInt8   is mod 2**8     with Size => 8;
   type UInt32  is mod 2**32    with Size => 32;

   HEADER_BYTE           : constant Byte := 16#AA#;
   STUFF_BYTE            : constant Byte := 16#55#;
   EOF_BYTE              : constant Byte := 16#55#;

   SEARCHING_FOR_SOF     : constant UInt4 := 0;
   RECEIVING_ID_CONTROL  : constant UInt4 := 1;
   RECEIVING_SEQ         : constant UInt4 := 2;
   RECEIVING_LENGTH      : constant UInt4 := 3;
   RECEIVING_PAYLOAD     : constant UInt4 := 4;
   RECEIVING_CHECKSUM_3  : constant UInt4 := 5;
   RECEIVING_CHECKSUM_2  : constant UInt4 := 6;
   RECEIVING_CHECKSUM_1  : constant UInt4 := 7;
   RECEIVING_CHECKSUM_0  : constant UInt4 := 8;
   RECEIVING_EOF         : constant UInt4 := 9;

   type App_ID is mod 2**6
      with Size => 6;

   type Frame_Header is record
      Header_0      : UInt8;
      Header_1      : UInt8;
      Header_2      : UInt8;
      ID            : App_ID;
      Reserved      : Bit;
      Transport     : Bit;
   end record with Size => 32;
   pragma Pack (Frame_Header);

   type Min_Payload is array (0 .. 255) of UInt8;

   type Crc32_Context is record
      Crc   : UInt32;
   end record;

   type Min_Context is record
      Rx_Frame_Payload_Buffer   : UInt8;
         --  Payload received so far

      Rx_Frame_Checksum         : UInt8;
         --  Checksum received over the wire

      Rx_Checksum               : Crc32_Context;
         --  Calculated checksum for receiving frame

      Tx_Checksum               : Crc32_Context;
         --  Calculated checksum for sending frame

      Rx_Header_Bytes_Seen      : UInt8;
         --  Countdown of header bytes to reset state

      Rx_Frame_State            : UInt4;
         --  State of receiver

      Rx_Frame_Payload_Bytes    : UInt8;
         --  Length of payload received so far

      Rx_Frame_ID_Control       : UInt8;
         --  ID and control bit of frame being received

      Rx_Frame_Seq              : UInt8;
         --  Sequence number of frame being received

      Rx_Frame_Length           : UInt8;
         --  Length of frame

      Rx_Control                : UInt8;
         --  Control byte

      Tx_Header_Byte_Countdown  : UInt8;
         --  Count out the header bytes

      Port                      : UInt8;
         --  Number of the port associated with the context
   end record;

   procedure Send_Frame (
      Context           : Min_Context;
      ID                : App_ID;
      Payload           : Min_Payload;
      Payload_Length    : UInt8
   );

   procedure Rx_Bytes (
      Context   : in out Min_Context;
      Data      : Byte
   );

end Min_Ada;
