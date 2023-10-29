with Min_Ada;
with Ada.Text_IO; use Ada.Text_IO;

procedure Run is
   Context : Min_Ada.Min_Context;
   Payload : Min_Ada.Min_Payload;
begin
   Min_Ada.Min_Init_Context(Context);
   Payload(0) := 2;
   Payload(1) := 3;
   Min_Ada.Send_Frame(Context, 5, Payload, 2);
   --Put_Line ("This is a test");
end Run;