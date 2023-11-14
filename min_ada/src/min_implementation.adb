with Min_Ada; use Min_Ada;
with Ada.Text_IO; use Ada.Text_IO;

package body Min_Implementation is

   procedure Tx_Byte_Impl (
      Data : Byte
   ) is
   begin
      Put_Line (Data'Image);
   end Tx_Byte_Impl;

end Min_Implementation;