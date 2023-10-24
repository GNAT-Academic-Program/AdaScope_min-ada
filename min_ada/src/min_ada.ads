package Min_Ada is

   type Bit     is mod 2**1     with Size => 1;
   type Byte    is mod 2**8     with Size => 8;
   type UInt8   is mod 2**8     with Size => 8;
   type UInt32  is mod 2**32    with Size => 32;

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

      Rx_header_bytes_seen      : UInt8;
         --  Countdown of header bytes to reset state

      Rx_frame_state            : UInt8;
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

end Min_Ada;
