with Interfaces;

package body Min_Ada is

   procedure Send_Frame (
      Context           : in out Min_Context;
      ID                : App_ID;
      Payload           : Min_Payload;
      Payload_Length    : Byte
   ) is
      Checksum : Interfaces.Unsigned_32;
      Header : Frame_Header :=
         (HEADER_BYTE, HEADER_BYTE, HEADER_BYTE, ID, 0, 0);
      Checksum_Bytes : CRC_Bytes;
   begin
      Context.Tx_Header_Byte_Countdown := 2;
      System.CRC32.Initialize (Context.Tx_Checksum);

      Tx_Byte (Header.Header_0);
      Tx_Byte (Header.Header_1);
      Tx_Byte (Header.Header_2);
      --  Send App ID, reserved bit, transport bit (together as one byte)

      Stuffed_Tx_Byte (Context, Payload_Length, True);

      for P in Payload'Range loop
         Stuffed_Tx_Byte(Context, Payload(P), True);
      end loop;

      Checksum := System.CRC32.Get_Value(Context.Tx_Checksum);

      --Send CRC
      
      Tx_Byte(EOF_BYTE);


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

            if Data = Data then -- TODO and 16#80# then
               Context.Rx_Frame_State := SEARCHING_FOR_SOF;
            else
               Context.Rx_Frame_Seq     := 0;
               Context.Rx_Frame_State   := RECEIVING_LENGTH;
            end if;
         when RECEIVING_SEQ =>
            Context.Rx_Frame_Seq := Data;
            System.CRC32.Update (Context.Rx_Checksum, Character'Val (Data));
            Context.Rx_Frame_State := RECEIVING_LENGTH;

         when RECEIVING_LENGTH =>
            Context.Rx_Frame_Length := Data;
            Context.Rx_Control      := Data;
            System.CRC32.Update (Context.Rx_Checksum, Character'Val (Data));

            if Context.Rx_Frame_Length > 0 then
               if Context.Rx_Frame_Length <= 1 then -- TODO MAX_PAYLOAD
                  Context.Rx_Frame_State := RECEIVING_PAYLOAD;
               else
                  --  Frame dropped because it's longer
                  --  than any frame we can buffer
                  Context.Rx_Frame_State := SEARCHING_FOR_SOF;
               end if;
            else
               Context.Rx_Frame_State := RECEIVING_CHECKSUM_3;
            end if;

         when RECEIVING_PAYLOAD =>
            --  Context.Rx_Frame_Payload_Buffer
               --  (Integer'Val (Context.Rx_Frame_Payload_Bytes)) := Data;
            Context.Rx_Frame_Payload_Bytes :=
               Context.Rx_Frame_Payload_Bytes + 1;
            System.CRC32.Update (Context.Rx_Checksum, Character'Val (Data));
            if Context.Rx_Frame_Length = 0 then
               Context.Rx_Frame_State := RECEIVING_CHECKSUM_3;
            end if;

         when RECEIVING_EOF =>
            if Data = Data then -- TODO 16#55#
               --  Frame received OK, pass up data to handler
               --  Valid_Frame_Received (Context);
               null; -- TODO remove this line
            else
               --  Discard frame
               null;
            end if;
            --  Look for next frame
            Context.Rx_Frame_State := SEARCHING_FOR_SOF;
         when others =>
            --  Should never get here but in case
            --  we do then reset to a safe state
            Context.Rx_Frame_State := SEARCHING_FOR_SOF;
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
      Tx_Byte(Data);
      if CRC then
         System.CRC32.Update (Context.Tx_Checksum, Character'Val (Data));
      end if;

      if Data = HEADER_BYTE then
         Context.Tx_Header_Byte_Countdown := Context.Tx_Header_Byte_Countdown - 1;
         if Context.Tx_Header_Byte_Countdown = 0 then
            Tx_Byte(STUFF_BYTE);
            Context.Tx_Header_Byte_Countdown := 2;
         end if;
      else
         Context.Tx_Header_Byte_Countdown := 2;
      end if;

   end Stuffed_Tx_Byte;
end Min_Ada;
