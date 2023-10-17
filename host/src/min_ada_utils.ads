package Min_Ada_Utils is
   ACK                   : constant Integer := 16#FF#;
   RESET                 : constant Integer := 16#FE#;

   HEADER_BYTE           : constant Integer := 16#AA#;
   STUFF_BYTE            : constant Integer := 16#55#;
   EOF_BYTE              : constant Integer := 16#55#;

   SEARCHING_FOR_SOF     : constant Integer := 0;
   RECEIVING_ID_CONTROL  : constant Integer := 1;
   RECEIVING_LENGTH      : constant Integer := 2;
   RECEIVING_SEQ         : constant Integer := 3;
   RECEIVING_PAYLOAD     : constant Integer := 4;
   RECEIVING_CHECKSUM_3  : constant Integer := 5;
   RECEIVING_CHECKSUM_2  : constant Integer := 6;
   RECEIVING_CHECKSUM_1  : constant Integer := 7;
   RECEIVING_CHECKSUM_0  : constant Integer := 8;
   RECEIVING_EOF         : constant Integer := 9;

   type Min_Frame is record
       Min_Id            : Integer;
       Payload           : Integer;
       Seq               : Integer;
       Is_Transport      : Integer;
       Last_Sent_Time    : Integer;
   end record;

   type Min_Frame_Array is
      array (Integer range 1 .. 10) of Min_Frame;

   type Min_Transport is record
      Transport_Fifo_Size           : Integer;
      Ack_Retransmit_Timeout_Ms     : Integer;
      Max_Window_Size               : Integer;
      Idle_Timeout_Ms               : Integer;
      Frame_Retransmit_Timeout_Ms   : Integer;
      Rx_Window_Size                : Integer;

      --  Stats about the link
      Longest_Transport_Fifo        : Integer;

      Dropped_Frames                : Integer;
      Spurious_Acks                 : Integer;
      Mismatched_Acks               : Integer;
      Duplicate_Frames              : Integer;
      Retransmitted_Frames          : Integer;
      Resets_Received               : Integer;
      Sequence_Mismatch_Drops       : Integer;

      --  State of transport FIFO
      Transport_Fifo                : Min_Frame_Array;
      Last_Sent_Ack_Time_Ms         : Integer;
      Last_Received_Anything_Ms     : Integer;
      Last_Received_Frame_Ms        : Integer;
      Last_Sent_Frame_Ms            : Integer;

      --  State for receiving a MIN frame
      --  Rx_Frame_Buf = bytearray()
      Rx_Header_Bytes_Seen          : Integer;
      Rx_Frame_State                : Integer;
      Rx_Frame_Checksum             : Integer;
      --  Rx_Payload_Bytes          : = bytearray()
      Rx_Frame_Id_Control           : Integer;
      Rx_Frame_Seq                  : Integer;
      Rx_Frame_Length               : Integer;
      Rx_Control                    : Integer;
      --  Accepted_Min_Frames            : = []
      --  Rx_List = []
      --  Stashed_Rx_Dict = {}

      --  Sequence numbers
      Rn                            : Integer;
      Sn_Min                        : Integer;
      Sn_Max                        : Integer;

      --  NACK status
      --  Nack_Outstanding = None

      --  transport_fifo_reset()
   end record;

   procedure Transport_Fifo_Pop (
      Transport                 : in out Min_Transport;
      New_Min_Transport_Fifo    : out Min_Frame_Array
   );

   function Transport_Fifo_Get (
      Transport         : Min_Transport;
      Frame_Number      : Integer
   ) return Min_Frame;

   procedure Transport_Fifo_Send (
      Transport         : Min_Transport;
      Frame             : Min_Frame
   );

   procedure Send_Ack (
      Transport         : Min_Transport
   );

   procedure Send_Nack (
      Transport         : Min_Transport;
      Frame_Number      : Integer
   );

   procedure Send_Reset (
      Transport         : Min_Transport
   );

   procedure Transport_Fifo_Reset (
      Transport         : in out Min_Transport
   );

   procedure Rx_Reset (
      Transport         : Min_Transport
   );

   procedure Transport_Reset (
      Transport         : Min_Transport
   );

   procedure Send_Frame (
      Transport         : Min_Transport;
      Min_Id            : Integer;
      Payload           : Integer -- TODO bytes
   );

   procedure Queue_Frame (
      Transport         : Min_Transport;
      Min_Id            : Integer;
      Payload           : Integer -- TODO bytes
   );

   procedure Min_Frame_Received (
      Transport         : Min_Transport;
      Min_Id_Control    : Integer;
      Min_Payload       : Integer; -- TODO bytes
      Min_Seq           : Integer
   );

   procedure Rx_Bytes (
      Transport         : Min_Transport;
      Data              : Integer -- TODO bytes
   );

   function On_Wire_Bytes (
      Transport         : Min_Transport;
      Frame             : Min_Frame
   ) return Integer; -- TODO bytes

   --  TODO CRC32

   function Transport_Stats (
      Transport         : Min_Transport
   ) return Integer; -- TODO return a bunch of stuff

   function Find_Oldest_Frame (
      Transport         : Min_Transport
   ) return Integer; -- TODO Min_Frame

   procedure Poll (
      Transport         : Min_Transport
   );

   procedure Close (
      Transport         : Min_Transport
   );

   function Now_Ms (
      Transport         : Min_Transport
   ) return Integer; -- TODO time

   procedure Serial_Write (
      Transport         : Min_Transport;
      Data              : Integer -- TODO data
   );

   function Serial_Real_All (
      Transport         : Min_Transport
   ) return Integer; -- TODO data

   procedure Serial_Close (
      Transport         : Min_Transport
   );

   procedure Testing (Test : String);

end Min_Ada_Utils;
