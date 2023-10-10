package body Min_ada_target is

   TRANSPORT_FIFO_SIZE_FRAMES_MASK : UInt8 := 15;
   TRANSPORT_FIFO_SIZE_FRAME_DATA_MASK : UInt16 := 1023;

   function ON_WIRE_SIZE
      (payload_len : UInt8) return UInt8 is
   begin
      return payload_len + 11;
   end ON_WIRE_SIZE;

   function min_queue_frame
      (self : min_context_Acc;
       min_id : UInt8;
       payload : payload_Arr;
       payload_len : UInt8) return Boolean is
   begin
      return True;
   end min_queue_frame;

   function min_has_space_for_frame
      (self : min_context_Acc;
       payload_len : UInt8) return Boolean is
   begin
      return True;
   end min_has_space_for_frame;

   procedure min_send_frame
      (self : min_context_Acc;
       min_id : UInt8;
       payload : payload_Arr;
       payload_len : UInt8) is
   begin
      if ON_WIRE_SIZE (payload_len) <= min_tx_space
   end min_send_frame;

   procedure min_poll
      (self : min_context_Acc;
       buf : buffer;
       buf_len : UInt32) is
   begin
      null;
   end min_poll;

   procedure min_transport_reset
      (self : min_context_Acc;
       inform_other_side: Boolean) is
   begin
      null;
   end min_transport_reset;

   procedure min_application_handler
      (min_id : UInt8;
       min_payload : payload_Arr;
       len_payload : UInt8;
       port: UInt8) is
   begin
      null;
   end min_application_handler;

   function min_time_ms return UInt32 is
   begin
      return 1;
   end min_time_ms;

   function min_tx_space
      (port : UInt8) return UInt16 is
   begin
      return 1;
   end min_tx_space;
   
   procedure min_tx_byte
      (port : UInt8;
       byte: UInt8) is
   begin
      null;
   end min_tx_byte;

   procedure min_tx_start
      (port : UInt8) is
   begin
      null;
   end min_tx_start;

   procedure min_tx_finished
      (port : UInt8) is
   begin
      null;
   end min_tx_finished;
   

end Min_ada_target;