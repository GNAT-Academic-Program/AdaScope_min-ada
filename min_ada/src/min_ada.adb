with Ada.Text_IO;
package body Min_Ada is

   procedure Send_Frame (
      Context           : Min_Context;
      ID                : App_ID;
      Payload           : Min_Payload;
      Payload_Length    : UInt8
   ) is
   begin
      Ada.Text_IO.Put_Line ("Hello");
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
end Min_Ada;
