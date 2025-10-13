{ lib, ... }:
let
  logrotateStatusDir = "/var/lib/logrotate";

in
{
  environment.persistence.ephemeral.directories = [
    logrotateStatusDir
  ];

  services = {
    journald.audit = true;
    logrotate = {
      extraArgs = lib.mkAfter [
        "--state"
        "${logrotateStatusDir}/logrotate.status"
      ];
      settings."/var/log/audit/audit.log" = {
        frequency = "daily";
        compress = true;
        rotate = 10;
        size = "1G";
        dateext = true;
      };
    };
  };

  security = {
    auditd.enable = true;

    audit = {
      enable = true;
      backlogLimit = 8192;
      rules = [
        # Kexec usage
        "-a always,exit -F arch=b64 -S kexec_load -F key=KEXEC"

        # Root directory access/modification
        "-a always,exit -F arch=b64 -F dir=/root -F key=roothomeaccess -F perm=war"

        # Failed Modifications of critical paths
        "-a always,exit -F arch=b64 -S open -F dir=/etc -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/bin -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/var -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/home -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/srv -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/opt -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/boot -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/nix -F success=0 -F key=unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/persist -F success=0 -F key=unauthedfileaccess"

        # User modifications
        "-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -S open -F a1&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -S open -F a1&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -S open -F a1&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -S open -F a1&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify"

        # Group modifications
        "-a always,exit -F arch=b32 -F path=/etc/passwd -F perm=wa -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -F path=/etc/passwd -F perm=wa -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -F path=/etc/shadow -F perm=wa -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -F path=/etc/shadow -F perm=wa -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -F path=/etc/group -F perm=wa -F auid>=1000 -F auid!=unset -F key=group-modify"
        "-a always,exit -F arch=b64 -F path=/etc/group -F perm=wa -F auid>=1000 -F auid!=unset -F key=group-modify"
        "-a always,exit -F arch=b32 -F path=/etc/gshadow -F perm=wa -F auid>=1000 -F auid!=unset -F key=group-modify"
        "-a always,exit -F arch=b64 -F path=/etc/gshadow -F perm=wa -F auid>=1000 -F auid!=unset -F key=group-modify"

        # Config changes indiciating possible privilege escalation
        "-a always,exit -F arch=b32 -F path=/etc/sudoers -F perm=wa -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/etc/sudoers -F perm=wa -F key=special-config-changes"

        # Accessing the audit log
        "-a always,exit -F arch=b32 -F dir=/var/log/audit/ -F perm=r -F auid>=1000 -F auid!=unset -F key=access-audit-trail"
        "-a always,exit -F arch=b64 -F dir=/var/log/audit/ -F perm=r -F auid>=1000 -F auid!=unset -F key=access-audit-trail"
        # File deletion events by users
        "-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -F key=delete"

        # Root command executions
        "-a always,exit -F arch=b64 -F euid=0 -F auid>=1000 -F auid!=-1 -S execve -F key=rootcmd"

        # Unsuccessful permission change
        "-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-perm-change"
        "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-perm-change"
        "-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-perm-change"
        "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-perm-change"

        # Successful permission change
        "-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change"
        "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-perm-change"

        # Unsuccessful ownership change
        "-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat,file_setattr -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-owner-change"
        "-a always,exit -F arch=b64 -S lchown,fchown,chown,fchownat,file_setattr -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-owner-change"
        "-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat,file_setattr -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-owner-change"
        "-a always,exit -F arch=b64 -S lchown,fchown,chown,fchownat,file_setattr -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-owner-change"

        # Successful ownership change
        "-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat,file_setattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-owner-change"
        "-a always,exit -F arch=b64 -S lchown,fchown,chown,fchownat,file_setattr -F success=1 -F auid>=1000 -F auid!=unset -F key=successful-owner-change"

        # Accessing SSH configuration
        "-a always,exit -F arch=b32 -F dir=/etc/ssh -F perm=war -F auid>=1000 -F auid!=unset -F key=access-ssh-config"
        "-a always,exit -F arch=b64 -F dir=/etc/ssh  -F perm=war -F auid>=1000 -F auid!=unset -F key=access-ssh-config"
      ];

    };
  };
}
