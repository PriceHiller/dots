{
  persist-dir,
  pkgs,
  config,
  ...
}:
let
  laurel-user = "_laurel";
in
{
  security = {
    audit.enable = true;
    wrappers.laurel = {
      source = "${pkgs.laurel}/bin/laurel";
      owner = "root";
      group = "${laurel-user}";
      permissions = "u=rwx,g=rx,o=";
    };
    auditd.enable = true;
  };
  # Ensure the wrapped laurel service is available in time for auditd
  systemd.services.suid-sgid-wrappers.before = [ "auditd.service" ];
  users.groups."${laurel-user}" = { };
  users.users."${laurel-user}" = {
    isSystemUser = true;
    createHome = true;
    group = "${laurel-user}";
    home = "/var/log/laurel";
  };
  environment.etc = {
    "laurel/config.toml" = {
      user = "${laurel-user}";
      text = ''
        # Write log files relative to this directory
        directory = "${config.users.users."${laurel-user}".home}"
        # Drop privileges from root to this user
        user = "${laurel-user}"
        # The periodical time window in seconds for status information to be printed to Syslog.
        # Status report includes the running version, config and parsing stats.
        # Default is 0 --> no status reports.
        statusreport-period = 0
        # By default, audit events are read from stdin ("stdin"). Alternatively, they
        # can be consumed from an existing UNIX domain socket ("unix:/path/to/socket")
        input = "stdin"

        # A string that is written to the log on startup and
        # whenever Laurel writes a status report.
        # marker = "correct-horse-battery-staple"

        [auditlog]
        # Base file name for the JSONL-based log file. Set to "-" to log to stdout. In this case
        # other log file related settings will be ignored.
        file = "audit.log"
        # Rotate when log file reaches this size (in bytes)
        size = 5000000
        # When rotating, keep this number of generations around
        generations = 10
        # Grant read permissions on the log files to these users, using
        [transform]

        # "array" (the default) causes EXECVE a0, a1, a2 … arguments to be
        # output as a list of strings, "ARGV". This is the default, it allows
        # analysts to reliably reproduce what was executed.
        #
        # "string" causes arguments to be concatenated into a single string,
        # separated by space characters, "ARGV_STR". This form allows for
        # easier grepping, but it is impossible to tell if space characters in
        # the resulting string are a separator or were part of an individual
        # argument in the original command line.

        execve-argv = [ "array" ]

        # execve-argv = [ "array", "string" ]

        # Trim excessively long EXECVE.ARGV and EXECVE.ARGV_STR entries.
        # Excess is cut from the middle of the argument list and a marker
        # indicating how many arguments / bytes have been cut is inserted.

        # execve-argv-limit-bytes = 10000

        [translate]

        # Perform translations of numeric values that can also be done by
        # auditd if configured with log_format=ENRICHED.

        # arch, syscall, sockaddr structures
        universal = false
        # UID, GID values
        user-db = false
        # Drop raw (numeric) syscall, arch, UID, GID values if they are translated
        drop-raw = false

        [enrich]

        # Add context (event-id, comm, exe, ppid) for *pid entries
        pid = true

        # List of environment variables to log for every EXECVE event
        execve-env = [ "LD_PRELOAD", "LD_LIBRARY_PATH" ]

        # Add container context to SYSCALL-based events
        container = true

        # Add script context to SYSCALL execve events
        script = true

        # Add groups that the user (uid) is a member of. Default: true
        user-groups = true

        [label-process]

        [filter]
        filter-null-keys = false
        filter-action = "drop"
      '';
    };
    "audit/plugins.d/laurel.conf".text = ''
      active = yes
      direction = out
      type = always
      path = ${config.security.wrapperDir}/laurel
      format = string
      args = --config /etc/laurel/config.toml
    '';
  };
  security.audit.rules = [
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
    "-a always,exit -F arch=b64 -S open -F dir=${persist-dir} -F success=0 -F key=unauthedfileaccess"

    # File deletion events by users
    "-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -F key=delete"

    # Root command executions
    "-a always,exit -F arch=b64 -F euid=0 -F auid>=1000 -F auid!=-1 -S execve -F key=rootcmd"
  ];
}
