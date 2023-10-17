with Min_ada_target;
with Ada.Text_IO; use Ada.Text_IO;

procedure Min_Ada is
   package MIN renames Min_ada_target;
   D  : MIN.min_context_Acc   := new MIN.min_context;
begin
   MIN.min_init_context(D, 1);
   Put_Line(D.port'Image);
   Put_Line("hello");
end Min_Ada;