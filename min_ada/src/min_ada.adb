package body Min_Ada is

   procedure Send_Frame (
      Context           : in out Min_Context;
      ID                : App_ID;
      Payload           : Min_Payload;
      Payload_Length    : Byte
   ) is
      Checksum : System.CRC32.CRC32;
      Header : Frame_Header :=
         (HEADER_BYTE, HEADER_BYTE, HEADER_BYTE, ID, 0, 0);
   begin
      System.CRC32.Initialize (Checksum);

      Tx_Byte (Header.Header_0);
      Tx_Byte (Header.Header_1);
      Tx_Byte (Header.Header_2);
      --  Send ID Control

      Stuffed_Tx_Byte (Context, Payload_Length, True);

   end Send_Frame;

   procedure Rx_Bytes (
      Context   : in out Min_Context;
      Data      : Byte
   ) is
   begin
      if Context.Rx_Header_Bytes_Seen = 2 then
         Context.Rx_Header_Bytes_Seen := 0;

         if Data = HEADER_BYTE then
            Context.Rx_Frame_State := RECEIVING_ID_CONTROL;
            return;

         elsif Data = STUFF_BYTE then
            --  Discard byte and carry on receiving the next character
            return;
         else
            --  Something has gone wrong. Give up on frame and look for header
            Context.Rx_Frame_State := SEARCHING_FOR_SOF;
            return;
         end if;
      end if;

      if Data = HEADER_BYTE then
         Context.Rx_Header_Bytes_Seen := Context.Rx_Header_Bytes_Seen + 1;
      else
         Context.Rx_Header_Bytes_Seen := 0;
      end if;

      case Context.Rx_Frame_State is
         when SEARCHING_FOR_SOF =>
            null;
         when RECEIVING_ID_CONTROL =>
            Context.Rx_Frame_ID_Control     := Data;
            Context.Rx_Frame_Payload_Bytes  := Data;
            System.CRC32.Initialize (Context.Rx_Checksum);
            System.CRC32.Update (Context.Rx_Checksum, Character'Val (Data));
         when others =>
            null;
      end case;

   end Rx_Bytes;

   procedure Tx_Byte (
      Data : Byte
   ) is
   begin
      null;
   end Tx_Byte;

   procedure Stuffed_Tx_Byte (
      Context   : in out Min_Context;
      Data      : Byte;
      CRC       : Boolean
   ) is
   begin
      if CRC then
         System.CRC32.Update (Context.Tx_Checksum, Character'Val (Data));
      end if;
   end Stuffed_Tx_Byte;
end Min_Ada;
