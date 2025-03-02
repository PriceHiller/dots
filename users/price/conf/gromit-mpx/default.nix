{ ... }:
{
  services.gromit-mpx = {
    enable = true;
    tools = [
      {
        device = "default";
        type = "pen";
        size = 5;
        color = "red";
      }
      {
        device = "default";
        type = "pen";
        size = 5;
        color = "blue";
        modifiers = [ "SHIFT" ];
      }
      {
        device = "default";
        type = "pen";
        size = 5;
        color = "yellow";
        modifiers = [ "CONTROL" ];
      }
      {
        device = "default";
        type = "pen";
        size = 6;
        color = "green";
        arrowSize = 1;
        modifiers = [ "2" ];
      }
      {
        device = "default";
        type = "eraser";
        size = 75;
        modifiers = [ "3" ];
      }
      {
        device = "default";
        color = "red";
        arrowSize = 5;
        modifiers = [
          "CONTROL"
          "SHIFT"
        ];
      }
      {
        device = "default";
        color = "blue";
        arrowSize = 5;
        modifiers = [
          "CONTROL"
          "SHIFT"
          "2"
        ];
      }
      {
        device = "default";
        color = "yellow";
        arrowSize = 5;
        modifiers = [
          "CONTROL"
          "SHIFT"
          "3"
        ];
      }
    ];
  };
}
