with Beta_Types; use Beta_Types;

package Min_ada_target is

   MAX_PAYLOAD : UInt8 := 255;
   TRANSPORT_FIFO_SIZE_FRAMES_BITS : UInt8 := 4;
   TRANSPORT_FIFO_SIZE_FRAME_DATA_BITS : UInt8 := 10;
   TRANSPORT_FIFO_MAX_FRAMES : UInt8 := 16;
   TRANSPORT_FIFO_MAX_FRAME_DATA : UInt16 := 1024;
   --Need to use unsigned ints (modular types in ada) and left shit (bitwise operation)

   type crc32_context is record

      crc     :   UInt32;

   end record;

   type transport_frame is record

      last_sent_time_ms   :   UInt32;
      payload_offset      :   UInt16;
      payload_len         :   UInt8;
      min_id              :   UInt8;
      seq                 :   UInt8;

   end record;

   type transport_frame_array is
      array (1 .. TRANSPORT_FIFO_MAX_FRAMES) of transport_frame;

   type transport_fifo is record

      frames                      :   transport_frame_array;
      last_sent_ack_time_ms       :   UInt32;
      last_received_anything_ms   :   UInt32;
      last_received_frame_ms      :   UInt32;
      dropped_frames              :   UInt32;
      spurious_acks               :   UInt32;
      sequence_mismatch_drop      :   UInt32;
      resets_received             :   UInt32;
      n_ring_buffer_bytes         :   UInt16;
      n_ring_buffer_bytes_max     :   UInt16;
      ring_buffer_tail_offset     :   UInt16;
      n_frames                    :   UInt8;
      n_frames_max                :   UInt8;
      head_idx                    :   UInt8;
      tail_idx                    :   UInt8;
      sn_min                      :   UInt8;
      sn_max                      :   UInt8;
      ring                        :   UInt8;

   end record;

   type UInt8_array_max is
      array (1 .. MAX_PAYLOAD) of UInt8;

   type min_context is record

      transport_fifo_min_context  :   transport_fifo;
      rx_frame_payload_buf        :   UInt8_array_max;
      rx_checksum                 :   crc32_context;
      tx_checksum                 :   crc32_context;
      rx_header_bytes_seen        :   UInt8;
      rx_frame_state              :   UInt8;
      rx_frame_payload_bytes      :   UInt8;
      rx_frame_id_control         :   UInt8;
      rx_frame_seq                :   UInt8;
      rx_frame_length             :   UInt8;
      rx_control                  :   UInt8;
      tx_header_byte_countdown    :   UInt8;
      port                        :   UInt8;

   end record;

   type min_context_Acc is access min_context;
   
   type buffer is
      array (1 .. 32) of Character;
   
   type payload_Arr is
      array (Integer range <>) of Character;

   --Need to check if pointers equivalent in ada is necessary
   --Check if const concept exists
   function min_queue_frame
      (self : min_context_Acc;
       min_id : UInt8;
       payload : payload_Arr;
       payload_len : UInt8) return Boolean;

   function min_has_space_for_frame
      (self : min_context_Acc;
       payload_len : UInt8) return Boolean;

   procedure min_send_frame
      (self : min_context_Acc;
       min_id : UInt8;
       payload : payload_Arr;
       payload_len : UInt8);

   procedure min_poll
      (self : min_context_Acc;
       buf : buffer;
       buf_len : UInt32);

   procedure min_transport_reset
      (self : min_context_Acc;
       inform_other_side: Boolean);

   procedure min_application_handler
      (min_id : UInt8;
       min_payload : payload_Arr;
       len_payload : UInt8;
       port: UInt8);

   function min_time_ms return UInt32;

   function min_tx_space
      (port : UInt8) return UInt16;
   
   procedure min_tx_byte
      (port : UInt8;
       byte: UInt8);

   procedure min_tx_start
      (port : UInt8);

   procedure min_tx_finished
      (port : UInt8);

end Min_ada_target;