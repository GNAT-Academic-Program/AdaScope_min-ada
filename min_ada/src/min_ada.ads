with System.CRC32;

package Min_Ada is

   type Bit     is mod 2**1     with Size => 1;
   type Byte    is mod 2**8     with Size => 8;
   type UInt4   is mod 2**4     with Size => 4;
   type UInt16  is mod 2**16    with Size => 16;
   type UInt32  is mod 2**32    with Size => 32;

   --IF TRANSPORT
   TRANSPORT_FIFO_MAX_FRAMES : constant Byte := 16;
   TRANSPORT_FIFO_MAX_FRAME_DATA : constant Byte := 1024;
   TRANSPORT_IDLE_TIMEOUT_MS : constant UInt32 := 1000;
   TRANSPORT_MAX_WINDOW_SIZE : constant Byte := 16;
   TRANSPORT_FIFO_SIZE_FRAMES_BITS : constant Byte := 4;
   TRANSPORT_FIFO_SIZE_FRAME_DATA_BITS : constant Byte := 10;
   TRANSPORT_FIFO_SIZE_FRAMES_MASK : constant Byte := 15;
   TRANSPORT_FIFO_SIZE_FRAME_DATA_MASK: constant UInt32 := 1023;


   MAX_PAYLOAD          : constant Byte := 255;

   HEADER_BYTE          : constant Byte := 16#AA#;
   STUFF_BYTE           : constant Byte := 16#55#;
   EOF_BYTE             : constant Byte := 16#55#;

   SEARCHING_FOR_SOF    : constant UInt4 := 0;
   RECEIVING_ID_CONTROL : constant UInt4 := 1;
   RECEIVING_SEQ        : constant UInt4 := 2;
   RECEIVING_LENGTH     : constant UInt4 := 3;
   RECEIVING_PAYLOAD    : constant UInt4 := 4;
   RECEIVING_CHECKSUM_4 : constant UInt4 := 5;
   RECEIVING_CHECKSUM_3 : constant UInt4 := 6;
   RECEIVING_CHECKSUM_2 : constant UInt4 := 7;
   RECEIVING_CHECKSUM_1 : constant UInt4 := 8;
   RECEIVING_EOF        : constant UInt4 := 9;

   type App_ID is mod 2**6
      with Size => 6;

   type Frame_Header is record
      Header_1      : Byte;
      Header_2      : Byte;
      Header_3      : Byte;
      ID            : App_ID;
      Reserved      : Bit;
      Transport     : Bit;
   end record with Size => 32;
   pragma Pack (Frame_Header);

   type Min_Payload is array (1 .. MAX_PAYLOAD) of Byte;

   type CRC_Bytes is array (1 .. 4) of Byte;

   type Tx_Byte_Acc is access procedure (Data: Byte);

   type Min_Tx_Space_Acc is access procedure;

   --IF TRANSPORT
   type Transport_Frame is record
      Last_Time_Sent_MS          : UInt32;
      Payload_Offset             : UInt16;
      Payload_Len                : Byte;
      Min_ID                     : Byte;
      Seq                        : Byte;
   end record;

   type Transport_Frames is array (1 .. TRANSPORT_FIFO_MAX_FRAMES) of Transport_Frame;

   --IF TRANSPORT
   type Transport_Fifo_Impl is record
      frames                     : Transport_Frames;
      Last_Sent_Ack_Time_MS      : UInt32;
      Last_Received_Anything_MS     : UInt32;
      Last_Received_Frame_MS     : UInt32;
      Dropped_Frames             : UInt32;
      Spurious_Acks              : UInt32;
      Sequence_Mismatch_Drop     : UInt32;
      Resets_Received            : UInt32;
      N_Ring_Buffer_Bytes        : UInt16;
      N_Ring_Buffer_Bytes_Max    : UInt16;
      Ring_Buffer_Tail_Offset    : UInt16;
      N_Frames                   : Byte;
      N_Frames_Max               : Byte;
      Head_Idx                   : Byte;
      Tail_Idx                   : Byte;
      Sn_Min                     : Byte;
      Sn_Max                     : Byte;
      Rn                         : Byte;
   end record;

   type Min_Context is record
      --IF TRANSPORT
      Transport_Fifo            : Transport_Fifo_Impl;

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

      Tx_Byte : Tx_Byte_Acc;

      Min_Tx_Space : Min_Tx_Space_Acc;

      
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

   procedure Stuffed_Tx_Byte (
      Context   : in out Min_Context;
      Data      : Byte;
      CRC       : Boolean
   );

   procedure Min_Init_Context (
      Context : in out Min_Context
   );

   procedure Valid_Frame_Received (
      Context   : Min_Context
   );

   function MSB_Is_One (
      Data : Byte
   ) return Boolean;

   procedure Min_Poll (
      Context : in out Min_Context;
      Data    : Byte
   );

   function Min_Time_MS return UInt32;
   

end Min_Ada;
