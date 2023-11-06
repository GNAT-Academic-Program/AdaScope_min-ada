with Min_Ada;
with Ada.Text_IO;
with GNAT.Serial_Communications;

procedure Run is
   Context : Min_Ada.Min_Context;
   Payload : Min_Ada.Min_Payload;
begin
   Min_Ada.Min_Init_Context (Context);
   Payload (1) := 2;
   Payload (2) := 3;
   --Min_Ada.Send_Frame (Context, 5, Payload, 2);
   Min_ada.Rx_Bytes(Context, 170);
   Min_ada.Rx_Bytes(Context, 170);
   Min_ada.Rx_Bytes(Context, 170);
   Min_ada.Rx_Bytes(Context, 5);
   Min_ada.Rx_Bytes(Context, 2);
   Min_ada.Rx_Bytes(Context, 2);
   Min_ada.Rx_Bytes(Context, 3);
   Min_ada.Rx_Bytes(Context, 190);
   Min_ada.Rx_Bytes(Context, 33);
   Min_ada.Rx_Bytes(Context, 200);
   Min_ada.Rx_Bytes(Context, 120);
   Min_ada.Rx_Bytes(Context, 85);
   --Ada.Text_IO.Put_Line ("Hello");
end Run;
