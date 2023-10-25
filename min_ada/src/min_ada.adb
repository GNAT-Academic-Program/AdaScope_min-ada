with Ada.Text_IO;
package body Min_Ada is

   procedure Send_Frame (
      Context           : in out Min_Context;
      ID                : App_ID;
      Payload           : Min_Payload;
      Payload_Length    : Byte
   ) is
   checksum : System.CRC32.CRC32;
   Header : Frame_Header := (HEADER_BYTE, HEADER_BYTE, HEADER_BYTE, ID, 0, 0);
   begin
      System.CRC32.Initialize(checksum);

      Tx_byte(Header.Header_0);
      Tx_byte(Header.Header_1);
      Tx_byte(Header.Header_2);
      --Send ID Control

      Stuffed_tx_byte(Context, Payload_Length, True);


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
            return;
         end if;
      end if;
   end Rx_Bytes;

   procedure Tx_Byte(
      Data : Byte
   ) is
   begin
      null;
   end;

   procedure Stuffed_tx_byte(
      Context : in out Min_Context;
      Data : Byte;
      CRC : Boolean
   ) is
   begin
      if CRC then
         System.CRC32.Update(Context.Tx_Checksum,  Character'Val(Data));
      end if;
   end;
end Min_Ada;
