{ ... }:
{
  # Distributes hardware interrupts across multiple processors
  #
  # Should increase performance a touch
  services.irqbalance.enable = true;
}
