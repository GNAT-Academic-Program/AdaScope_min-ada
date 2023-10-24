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
end Min_Ada;
