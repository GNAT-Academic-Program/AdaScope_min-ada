with Min_Ada;
with Ada.Text_IO;

procedure Run is
   Context : Min_Ada.Min_Context;
   Payload : Min_Ada.Min_Payload;
begin
   Min_Ada.Min_Init_Context (Context);
   Payload (1) := 2;
   Payload (2) := 3;
   Min_Ada.Send_Frame (Context, 5, Payload, 2);
   Ada.Text_IO.Put_Line ("Hello");
end Run;
