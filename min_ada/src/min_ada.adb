with Ada.Text_IO; use Ada.Text_IO;
with Interfaces; use Interfaces;

package body Min_Ada is

   now : UInt32;

   procedure Send_Frame (
      Context           : in out Min_Context;
      ID                : App_ID;
      Payload           : Min_Payload;
      Payload_Length    : Byte
   ) is
      Checksum          : Interfaces.Unsigned_32;
      Checksum_Bytes    : CRC_Bytes with Address => Checksum'Address;
      ID_Control        : Byte with Address => Header.ID'Address;
      Header            : Frame_Header :=
         (HEADER_BYTE, HEADER_BYTE, HEADER_BYTE, ID, 0, 0);
   begin
      Context.Tx_Header_Byte_Countdown := 2;
      System.CRC32.Initialize (Context.Tx_Checksum);

      Context.Tx_Byte (Header.Header_1);
      Context.Tx_Byte (Header.Header_2);
      Context.Tx_Byte (Header.Header_3);

      --  Send App ID, reserved bit, transport bit (together as one byte)
      Stuffed_Tx_Byte (Context, ID_Control, True);

      Stuffed_Tx_Byte (Context, Payload_Length, True);

      for P in 1 .. Payload_Length loop
         Stuffed_Tx_Byte (Context, Payload (P), True);
      end loop;

      Checksum := System.CRC32.Get_Value (Context.Tx_Checksum);

      Stuffed_Tx_Byte (Context, Checksum_Bytes (4), False);
      Stuffed_Tx_Byte (Context, Checksum_Bytes (3), False);
      Stuffed_Tx_Byte (Context, Checksum_Bytes (2), False);
      Stuffed_Tx_Byte (Context, Checksum_Bytes (1), False);

      --  Send CRC

      Context.Tx_Byte (EOF_BYTE);
   end Send_Frame;

   procedure Rx_Bytes (
      Context   : in out Min_Context;
      Data      : Byte
   ) is
      Real_Checksum     : Interfaces.Unsigned_32;
      Frame_Checksum    : Interfaces.Unsigned_32 with Address =>
         Context.Rx_Frame_Checksum'Address;
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
            Context.Rx_Frame_Payload_Bytes  := 0;
            System.CRC32.Initialize (Context.Rx_Checksum);
            System.CRC32.Update (Context.Rx_Checksum, Character'Val (Data));

            if MSB_Is_One (Data) then -- TODO if Data and 16#80#
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
               if Context.Rx_Frame_Length <= MAX_PAYLOAD then
                  Context.Rx_Frame_State := RECEIVING_PAYLOAD;
               else
                  --  Frame dropped because it's longer
                  --  than any frame we can buffer
                  Context.Rx_Frame_State := SEARCHING_FOR_SOF;
               end if;
            else
               Context.Rx_Frame_State := RECEIVING_CHECKSUM_4;
            end if;

         when RECEIVING_PAYLOAD =>
            Context.Rx_Frame_Payload_Buffer
               (Context.Rx_Frame_Payload_Bytes + 1) := Data;
            Context.Rx_Frame_Payload_Bytes :=
               Context.Rx_Frame_Payload_Bytes + 1;
            System.CRC32.Update (Context.Rx_Checksum, Character'Val (Data));
            Context.Rx_Frame_Length :=
               Context.Rx_Frame_Length - 1;
            if Context.Rx_Frame_Length = 0 then
               Context.Rx_Frame_State := RECEIVING_CHECKSUM_4;
            end if;

         when RECEIVING_CHECKSUM_4 =>
            Context.Rx_Frame_Checksum (4)   := Data;
            Context.Rx_Frame_State          := RECEIVING_CHECKSUM_3;

         when RECEIVING_CHECKSUM_3 =>
            Context.Rx_Frame_Checksum (3)   := Data;
            Context.Rx_Frame_State          := RECEIVING_CHECKSUM_2;

         when RECEIVING_CHECKSUM_2 =>
            Context.Rx_Frame_Checksum (2)   := Data;
            Context.Rx_Frame_State          := RECEIVING_CHECKSUM_1;

         when RECEIVING_CHECKSUM_1 =>
            Context.Rx_Frame_Checksum (1)   := Data;

            Real_Checksum := System.CRC32.Get_Value (Context.Rx_Checksum);
            if Frame_Checksum /= Real_Checksum then
            --  if Frame_Checksum /= Frame_Checksum then
               --  Frame fails the checksum and is dropped
               Context.Rx_Frame_State := SEARCHING_FOR_SOF;
            else
               Context.Rx_Frame_State := RECEIVING_EOF;
            end if;

         when RECEIVING_EOF =>
            if Data = EOF_BYTE then
               --  Frame received OK, pass up data to handler
               Valid_Frame_Received (Context);
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

   procedure Valid_Frame_Received (
      Context : Min_Context
   ) is
   begin
      Put ("Rx_Frame_ID_Control: ");
      Put_Line (Context.Rx_Frame_ID_Control'Image);
      Put ("Rx_Frame_Payload_Bytes: ");
      Put_Line (Context.Rx_Frame_Payload_Bytes'Image);

      for P in 1 .. Context.Rx_Frame_Payload_Bytes loop
         Put ("Payload: ");
         Put_Line (Context.Rx_Frame_Payload_Buffer (P)'Image);
      end loop;
   end Valid_Frame_Received;

   procedure Stuffed_Tx_Byte (
      Context   : in out Min_Context;
      Data      : Byte;
      CRC       : Boolean
   ) is
   begin
      Context.Tx_Byte (Data);
      if CRC then
         System.CRC32.Update (Context.Tx_Checksum, Character'Val (Data));
      end if;

      if Data = HEADER_BYTE then
         Context.Tx_Header_Byte_Countdown :=
            Context.Tx_Header_Byte_Countdown - 1;

         if Context.Tx_Header_Byte_Countdown = 0 then
            Context.Tx_Byte (STUFF_BYTE);
            Context.Tx_Header_Byte_Countdown := 2;
         end if;
      else
         Context.Tx_Header_Byte_Countdown := 2;
      end if;

   end Stuffed_Tx_Byte;

   procedure Min_Init_Context (
      Context : in out Min_Context
   ) is
   begin
      Context.Rx_Header_Bytes_Seen := 0;
      Context.Rx_Frame_State := SEARCHING_FOR_SOF;

      --IF TRANSPORT
      Context.Transport_Fifo.Spurious_Acks := 0;
      Context.Transport_Fifo.Sequence_Mismatch_Drop := 0;
      Context.Transport_Fifo.Dropped_Frames := 0;
      Context.Transport_Fifo.Resets_Received := 0;
      Context.Transport_Fifo.N_Ring_Buffer_Bytes_Max := 0;
      Context.Transport_Fifo.N_Frames_Max := 0;
   

   end Min_Init_Context;

   function MSB_Is_One (
      Data : Byte
   ) return Boolean is
      MSB : Interfaces.Unsigned_8;
   begin
      MSB := Interfaces.Shift_Right (
         Value  => Interfaces.Unsigned_8 (Data),
         Amount => 7
      );
      if MSB = 1 then
         return True;
      else
         return False;
      end if;
   end MSB_Is_One;

   function Min_Time_MS return UInt32 is
   begin
      --TODO
      return 2;
   end Min_Time_MS;


   --TODO
   --Need to not rx_bytes if min_poll called without data. Done automatically in c implementation if buffer size is 0;
   procedure Min_Poll (
      Context : in out Min_Context;
      Data    : Byte
   ) is
      --IF TRANSPORT
      Window_Size : Byte;
      Remote_Connected : Boolean;
      Remote_Active : Boolean;
      Frame_Index : Byte;
   begin
      Rx_Bytes(Context, Data);

      --IF TRANSPORT
      now := Min_Time_MS;
      Remote_Connected := ((now - Context.Transport_Fifo.Last_Received_Anything_MS < TRANSPORT_IDLE_TIMEOUT_MS));
      Remote_Active := ((now - Context.Transport_Fifo.Last_Received_Frame_MS < TRANSPORT_IDLE_TIMEOUT_MS));

      Window_Size := Context.Transport_Fifo.Sn_Max - Context.Transport_Fifo.Sn_Min;
      if (Window_Size < TRANSPORT_MAX_WINDOW_SIZE) and (Context.Transport_Fifo.N_Frames > Window_Size) then
         Frame_Index := (Context.Transport_Fifo.Head_Idx + Window_Size) and TRANSPORT_FIFO_SIZE_FRAMES_MASK;
         --TODO - ON_WIRE_SIZE
         Context.Transport_Fifo.Frames(Frame_Index).seq := Context.Transport_Fifo.Sn_Max;

      end if;


   end Min_Poll;

end Min_Ada;
