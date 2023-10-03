with Beta_Types; use Beta_Types;

package Min_ada_target is

   MAX_PAYLOAD : Integer := 250;
   TRANSPORT_FIFO_SIZE_FRAMES_BITS : Integer := 4;
   TRANSPORT_FIFO_SIZE_FRAME_DATA_BITS : Integer := 10;
   TRANSPORT_FIFO_MAX_FRAMES : Integer := 4;
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

      transport_fifo_min_context              :   transport_fifo;
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

   --Need to check if pointers equivalent in ada is necessary
   function min_queue_frame
      (self : min_context;
       min_id : UInt8) return Boolean;

end Min_ada_target;