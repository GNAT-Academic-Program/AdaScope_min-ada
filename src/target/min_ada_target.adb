package body Min_ada_target is

   function min_queue_frame
      (self : min_context;
       min_id : UInt8;
       payload : UInt8;
       payload_len : UInt8) return Boolean is
   begin
      return True;
   end min_queue_frame;

   function min_has_space_for_frame
      (self : min_context;
       payload_len : UInt8) return Boolean is
   begin
      return True;
   end min_has_space_for_frame;

end Min_ada_target;