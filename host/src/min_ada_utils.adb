with Ada.Text_IO; use Ada.Text_IO;

package body Min_Ada_Utils is
   procedure Transport_Fifo_Pop (
      Transport                 : in out Min_Transport;
      New_Min_Transport_Fifo    : out Min_Ada_Utils.Min_Frame_Array
   ) is
   begin
      if Transport.Transport_Fifo'Size <  2 then
         null;
      else
         New_Min_Transport_Fifo :=
            Transport.Transport_Fifo (2 .. Transport.Transport_Fifo'Last);
            Transport.Transport_Fifo := New_Min_Transport_Fifo;
      end if;
   end Transport_Fifo_Pop;

   function Transport_Fifo_Get (
      Transport         : Min_Transport;
      Frame_Number      : Integer
   ) return Min_Frame is
   begin
      return Transport.Transport_Fifo (Frame_Number);
   end Transport_Fifo_Get;

   procedure Transport_Fifo_Send (
      Transport         : Min_Transport;
      Frame             : Min_Frame
   ) is
   begin
      Put_Line ("Hello");
   end Transport_Fifo_Send;

   procedure Send_Ack (
      Transport         : Min_Transport
   ) is
   begin
      Put_Line ("Hello");
   end Send_Ack;

   procedure Send_Nack (
      Transport         : Min_Transport;
      Frame_Number      : Integer
   ) is
   begin
      Put_Line ("Hello");
   end Send_Nack;

   procedure Send_Reset (
      Transport         : Min_Transport
   ) is
   begin
      Put_Line ("Hello");
   end Send_Reset;

   procedure Transport_Fifo_Reset (
      Transport         : in out Min_Transport
   ) is
   begin
      Put_Line ("Hello");
      --  TODO Transport.Transport_Fifo              := [];
      Transport.Last_Received_Anything_Ms   := Now_Ms (Transport);
      Transport.Last_Sent_Ack_Time_Ms       := Now_Ms (Transport);
      Transport.Last_Sent_Frame_Ms          := 0;
      Transport.Last_Received_Frame_Ms      := 0;
      Transport.Sn_Min                      := 0;
      Transport.Sn_Max                      := 0;
      Transport.Rn                          := 0;
   end Transport_Fifo_Reset;

   procedure Rx_Reset (
      Transport         : Min_Transport
   ) is
   begin
      Put_Line ("Hello");
   end Rx_Reset;

   procedure Transport_Reset (
      Transport         : Min_Transport
   ) is
   begin
      Send_Reset (Transport);
      Send_Reset (Transport);

      Transport_Reset (Transport);
      Rx_Reset (Transport);
   end Transport_Reset;

   procedure Send_Frame (
      Transport         : Min_Transport;
      Min_Id            : Integer;
      Payload           : Integer -- TODO bytes
   ) is
   begin
      Put_Line ("Hello");
   end Send_Frame;

   procedure Queue_Frame (
      Transport         : Min_Transport;
      Min_Id            : Integer;
      Payload           : Integer -- TODO bytes
   ) is
   begin
      Put_Line ("Hello");
   end Queue_Frame;

   procedure Min_Frame_Received (
      Transport         : Min_Transport;
      Min_Id_Control    : Integer;
      Min_Payload       : Integer; -- TODO bytes
      Min_Seq           : Integer
   ) is
   begin
      Put_Line ("Hello");
   end Min_Frame_Received;

   procedure Rx_Bytes (
      Transport         : Min_Transport;
      Data              : Integer -- TODO bytes
   ) is
   begin
      Put_Line ("Hello");
   end Rx_Bytes;

   function On_Wire_Bytes (
      Transport         : Min_Transport;
      Frame             : Min_Frame
   ) return Integer is -- TODO bytes
   begin
      return 10;
   end On_Wire_Bytes;

   --  TODO CRC32

   function Transport_Stats (
      Transport         : Min_Transport
   ) return Integer is -- TODO return a bunch of stuff
   begin
      return 10;
   end Transport_Stats;

   function Find_Oldest_Frame (
      Transport         : Min_Transport
   ) return Integer is
   begin
      return 10;
   end Find_Oldest_Frame;

   procedure Poll (
      Transport         : Min_Transport
   ) is
   begin
      Put_Line ("Hello");
   end Poll;

   procedure Close (
      Transport         : Min_Transport
   ) is
   begin
      Put_Line ("Hello");
   end Close;

   function Now_Ms (
      Transport         : Min_Transport
   ) return Integer is -- TODO time
   begin
      return 10;
   end Now_Ms;

   procedure Serial_Write (
      Transport         : Min_Transport;
      Data              : Integer -- TODO data
   ) is
   begin
      Put_Line ("Hello");
   end Serial_Write;

   function Serial_Real_All (
      Transport         : Min_Transport
   ) return Integer is -- TODO data
   begin
      return 10;
   end Serial_Real_All;

   procedure Serial_Close (
      Transport         : Min_Transport
   ) is
   begin
      Put_Line ("Hello");
   end Serial_Close;

   procedure Testing (
      Test : String
   ) is
   begin
      Put_Line (Test);
   end Testing;

end Min_Ada_Utils;
