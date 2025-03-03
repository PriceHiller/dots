{ ... }:
{
  services = {
    journald.audit = true;
    logrotate.settings."/var/log/audit/audit.log" = {
      frequency = "daily";
      compress = true;
      rotate = 3;
      size = "1G";
      dateext = true;
    };
  };
  security = {
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        # Program Executions
        "-a exit,always -F arch=b64 -S execve -F key=progexec"

        # Home path access/modification
        "-a always,exit -F arch=b64 -F dir=/home -F perm=war -F key=homeaccess"

        # Kexec usage
        "-a always,exit -F arch=b64 -S kexec_load -F key=KEXEC"

        # Root directory access/modification
        "-a always,exit -F arch=b64 -F dir=/root -F key=roothomeaccess -F perm=war"

        # Failed Modifications of critcal paths
        "-a always,exit -F arch=b64 -S open -F dir=/etc -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/bin -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/var -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/home -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/srv -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/opt -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/boot -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/nix -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/persist -F success=0 -F key=unauthedfileaccess"

        # File deletion events by users
        "-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -F key=delete"

        # Root command executions
        "-a always,exit -F arch=b64 -F euid=0 -F auid>=1000 -F auid!=-1 -S execve -F key=rootcmd"
      ];

    };
  };
}
