# Overhaul Goals

## Single source-of-truth for all configuration

- This means for the desired state
- Right now some important configuration actually is managed manually -- for example, Route53 DNS records
- I intend to use OpenTofu and [Colmena](https://github.com/nix-community/colmena) to manage deployments. There is a way to write Terraform configurations entirely in Nix provided by [Tofunix](https://tofunix.projects.tf/).
  - I want to use Tofunix, because it provides better validation than Terranix
  - The state file should be stored remotely on one of my hosts so automatic deployments can be done and automated drift detection becomes a possibility
    - If the host does not exist yet (Cold Start scenario) assume we're in a cold-start scenario
- Configuration drift detection may be an additional goal to explore later -- not part of the initial overhaul
- Nix will be the source-of-truth -- other configuration tools will consume from Nix
  - For example, OpenTofu will be handled in Tofunix for validation
- One notable issue: some hosts have dynamic public IPs
  - Some hosts are behind a consumer-level ISP router that dynamically rotates the public IP -- need a way to reconcile this
  - To resolve this a eventually consistent approach where these dynamic hosts handle updating their own records in DNS should be created
  - This means that not _all_ IPs can be defined directly in configuration

### Deployed as Layers

Each layer is responsible (a dependency) for the layer below it. A higher layer may actually deploy a lower layer as part of it, but a lower layer is not considered part of the critical responsibilities of a specific layer. For example, Layer 0 **_MAY NOT_** depend on Layer 1, as this would in turn create a cyclic dependency as Layer 1 is dependent on Layer 0.

#### Layer -1: Cold-Start Layer

This is the _only_ layer that may contain artifacts that exist outside of the configuration.

This layer is intended for a cold-start scenario where _nothing_ exists. Basically exists as offline recovery (or initial bootstrapping) material.

Contains:

- Recovery keys
  - Stored on a hardware token (Yubikey)
- Cold-start runbook(s) to stand up Layer 0
- Root CA or CA recovery path
- SSH CA recovery path
- Backup repository credentials
- Anything else that is a hard requirement for standing up layer 0 (to be determined later)
- Base installer image or a method of building one
- General operator guide/procedures

Contains the **authority** to recover all following layers, but it shouldn't have a fully duplicate of the runtime secrets -- it's just the bare minimum required to start standing things up.

#### Layer 0: Root Control Plane

This is where the core system(s) that provide secrets and state live -- they're considered the most important layer as everything else builds upon them.

This is the smallest deployed layer that can resume normal automation.

- We will define a single "Root" system that **_must_** not have anything in the critical path that depends on OpenBao
  - It can still have services that will fail because OpenBao is not up, but the OpenBao configuration itself cannot depend on itself being available
  - For example, the `root` or the SSH keys for this host **_CANNOT_** depend on OpenBao being available
  - This system must also provide a OpenTofu state backend
- Other hosts may run OpenBao, but at least one host must be identified as a "Root" host that doesn't create a cyclic dependency on secrets provisioning from OpenBao -- this allows standing up that first "root" host that the others can then provision off of
- In a cold-start scenario this layer must be provisioned first
  - Deployment is likely more manual than the other layers as this has a cyclic dependency on itself after being bootstrapped (for example, services running on this layer may have dependencies on the secrets in OpenBao, but if this is the actual layer being deployed, then OpenBao may not be up to hand out secrets)

Contains:

- OpenBao root instance
- OpenTofu state backend
- State backup/restore tooling
- Root/internal PKI services (or at least _intermediate_ CA services)
- SSH CA, if online
- Very minimal monitoring and logging for itself
- Deployment credentials
- A binary cache after cold-start

##### Modes

This layer will have two modes to support operations from a cold-start and in a normal (healthy) environment.

###### Cold-start Mode

In Bootstrap mode, OpenBao, the state backend, and other critical path dependencies are not available. This mode exists to _make_ them available for later layers. The goal of this mode is to transition into a **Normal** mode.

- Does not require OpenBao
- Does not require remote OpenTofu state
- Can be installed from Layer -1
- Minimal services only
- Accepts operator-supplied recovery material
- Can restore OpenBao & state backend from a backup if available

###### Normal Mode

Used after Bootstrap mode has finished setting up. Basically, critical dependencies now exist (like the secrets provider and state).

- Uses secrets provider normally
  - No longer uses secrets from an operator (except for what is strictly necessary outside of OpenBao)
- Uses remote state backend
- Participates in monitoring/logging
- Uses normal certs/tokens
- Can deploy/manage other layers

In Normal mode it is possible for Layer 0 to have a self-referential dependency, hence the need for two modes.

#### Layer 1: External Resources

This layer is managed via OpenTofu. Basically anything in the cloud will exist in this layer.

Deployed via Terraform/OpenTofu

- Route53 zones and records
- Object storage
- Provider-side IAM/API resources
- VPCs/networks
- DNS delegation
- Dynamic DNS permissions
- Possibly backup buckets/repos

#### Layer 2: Host Substrate

This layer is responsible for NixOS (and potentially other) host configuration.

NixOS hosts, disks, Wireguard, base monitoring, host identification.

- NixOS base config
- Disko layout
- LUKS
- TPM2 enrollment
- Secure Boot/measured boot config
- WireGuard
- SSH host certs
- Host OpenBao auth
- Base monitoring/logging
- Local firewall
- Impermanence
- Binary cache config
- Backup agent config
- Base systemd hardening defaults

Host enrollment is technically under this layer, but has a different flow expanded upon later.

#### Layer 3: Workloads/Services

This layer owns the actual services.

- Databases
- Web apps
- Internal services
- MicroVM workloads
- kubernetes workloads
- Service-level backup policies
- Service-level alerts
- mTLS service identities

#### Layer 4: Policy + Operations

Managed by CI and scheduled jobs as

- Monitoring
- Alerts
- Backup Testing
- Conformance checks

## Ease of covering non-NixOS deployments

- In the future I intend to create a Kubernetes cluster on top of the underlying NixOS hosts and would like to be able to configure them via Terraform
- I believe using Terraform (Tofunix) will cover this use-case

## Secure management of secrets

- Secrets should not exist in a state in which an attacker can easily get them
- I intend to manage secrets with Openbao
- To allow tokens etc. that are time-based to work as expected -- all systems should be deployed with NTP enabled along with an alarm for too much clock-drift
  - Not able to run a NTP source myself, lack hardware capability
  - Security issues around this
    - For now accept the trade-off -- secure NTP sources later on as a stretch goal

1. Out-of-band secrets management
   - Secrets should _not_ be stored as part of the repository -- whether encrypted in some other form
2. Centralization of secrets management
   - One source-of-truth for where secrets come from
3. Automatic secrets roll-out
   - This might mean using Terraform to deploy various systems
4. Secrets Leakage handling
   - For instance: a secret ending up in the Nix store is considered a _leaked_ secret
     - This means a CI job to detect `builtints.readFile (SOME_SECRET)` that requires explicit opt-out if detected to cover early-warning cases
     - Since a leak is almost inevitable at some point (mistakes happen in complex systems) -- a way to detect leaks is highly desired
       - For example, a job that runs at some interval that scans for leaked secrets in the Nix store Canary tokens to increase the likelihood of detecting breaches
5. Self-hosted management of secrets
   - Using secrets from say AWS KMS is not acceptable -- secrets should be managed entirely "in-house"
6. Bootstrapping should be possible if the central secrets provider is unavailable/down
   - Might mean using a "break-glass" key to kick off the bootstrapping process -- likely a hardware token (Yubikey)
7. Auto-unsealing
   - Should be handled with TPM2 for the "root" OpenBao instance
   - This root instance is considered production-critical -- **_must_** be treated as Layer 0 system
   - Non-"root" instances will be unsealed by Transit auto-unseal
   - Done via a "PKCS#11 Unseal"
   - This means **especially** for hosts that run OpenBao to provide secrets, they **_must_** run secure boot using TPM2 + attestation along with encryption at rest to defend against attackers
8. Internal PKI
   - SSH should be managed by a SSH CA
   - Internal X.509 PKI
   - mTLS between services
   - This will require regular rotation of certs and CA

## Enrolling new hosts should be trivial

- NixOS hosts:
  - Currently I use [disko](https://github.com/nix-community/disko) to declaratively partition and format disks
  - Right now the process I have for enrolling hosts is brittle, not particularly well-tested, and not often used -- meaning standing up new NixOS hosts is a time-consuming mistake-prone process
- Require TPM2 measured boot along with attestation
  - _Much_ later stretch goal: enforced remote attestation

### Provisioning new Machines

Enrolling an uncontrolled host (e.g. one lacking an OS, or not currently managed by our configuration)

Consider the system to be provisioned to be passing through the following states:

1. Uncontrolled
   - The system is currently not controlled by the configuration
   - It may be a host that is running a different OS (e.g. a VPS in AWS running Debian)
   - It may be a host that has _no_ OS installed and has a ephemeral OS running
   - We want to move the system into a state in which it _can_ be enrolled

2. Ready
   - The system has been put into a state in which it can be enrolled -- this means something like [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) has been ran on the host
   - Must notify us that it is ready to be enrolled
   - This means putting some sort of key or secret to allow it to be setup from configuration management
   - Likely will create a bootstrap base configuration that is built as an image an then installed to the host
     - This allows a common set of base tools etc. to be present in the **Ready** state

3. Attestation
   - The host has been identified as **Ready**
   - We must assert certain facts about the system
     - Does it support TPM2?
     - Does it have a large enough disk to actually be enrolled?
     - Is the architecture of the system supported?
     - Does the system have enough RAM to be enrolled?
     - Basically pre-checks to attest that the system has the following properties:
       1. Secure enough to actually be enrolled (or can be _made_ secure enough to be enrolled)
       2. The system has the required resources to be enrolled
       3. etc.?

4. Enrollment

   The system has passed **Attestation** and can now be enrolled

   This will have sub-stages:
   - Disk Provisioning
     - This stage will use [disko](https://github.com/nix-community/disko) to automate disk partitioning and formatting
       - As part of this will be setting up LUKS with TPM2 unlock
       - This means `systemd-cryptenroll` will likely need to be used at this stage
     - Once the disk has been setup, we setup the bare minimum needed for networking and put a simple public SSH key into the root's `authorized_keys` that will be used to login in the next sub-stage
     - We reboot once we're done
   - System Provisioning
     - **Disk Provisioning** has succeeded -- we are ready to apply remaining configuration
     - This stage will log into the system with a provisioned disk and apply the final configuration
     - This includes provisioning required secrets to the host

5. Enrolled
   - **Enrollment** has succeeded -- system is now tracked and managed by the configuration

## Centralized audit logging, monitoring, metrics and alerting

- Already done in my repository via Grafana, using Vector and Grafana loki
- Detection of systems in degraded or failed states
  - E.g. a Systemd service on some host fails -- I need to know (likely managed through centralized )
- I should be able to view the system log of any host from a single place
- Cert expiry **_must_** cause an alert

## Isolation of services

- I want to run with the assumption that largely _all_ services running are, at any point in time, potentially malware that are attempting to expand their access across the current system and gain lateral movement through the infrastructure
- I will assume the base NixOS system (no additional services etc. beyond what comes by default) is trusted
  - Without this, my assumption would mean that the core `systemd` init could be "malware" -- if it was I'm already pretty much screwed
- I intend to use [microvm.nix](https://github.com/microvm-nix/microvm.nix) to separate services as reasonable -- performance constraints may require a microvim to be applied coarsely due to resource limitations
- Later stretch goal: Egress network filtering
  - Later on what would be nice is DNS-based egress filtering with explicitly defined allow-lists for each contained service cluster within a given unit

## Automated Backups

- I'm thinking of using Restic to cover this use-case
- Must be a way to automatically test backups so restores and rollbacks are routine -- thus reducing anxiety and concerns on breaking infrastructure
  - Testing restores is important -- if a backup is taken, but there's no well-known and well-tested method of restoring it -- then the backup is not particularly useful and it creates concerns of breaking something as restoring it safely is non-trivial

## NixOS systems must be "ephemeral"

- Meaning anything that is not explicitly covered in configuration should be rolled back on reboots
- I should be able to explicitly permit certain paths to persist through reboots for state (e.g. postgresql data)
- This is currently done using BTRFS rollbacks to a "blank" root snapshot on reboots integrated with [Impermanence](https://github.com/nix-community/impermanence)

## Bootstrapping _must_ be a covered case

- Consider a case in which all systems are down and all I have in hand is the repository of configuration -- at this point in time the entire "world" must be re-built from scratch (I'm assuming literally all hosts have to be re-installed -- they lack an OS at this point in time)

## Local host management

- Consider that I work on my laptop (using NixOS) locally -- the laptop's configuration should be managed by this central configuration
- I need to able to deploy to this laptop locally if I have the repository checked out on it in addition to remote systems

## All systems **MUST** be encrypted at rest

- Aligns with security goals and secure boot setup

## Nix Binary cache

- Allow all systems to share builds if possible
- This means if system A is hosting the cache and system B builds a package, system B should push the signed package to system A's binary cache
- I already sort-of have this by using [Harmonia](https://github.com/nix-community/harmonia) and [nix-post-build-hook-queue](https://github.com/newAM/nix-post-build-hook-queue)
- Authentication & Authorization for this can be somewhat difficult -- have to be sure that an attacker can't upload "bad" paths into the cache
- Security: I will require at least 2 builds of the same package across different hosts before a build can be considered "attested" to (that being that a builder was not compromised) -- this means that the 2 different builds should produce the same hash
  - This will be a _stretch_ goal -- not intended for initial deployment, for now we'll trust all the uploaded builds by default to ease this overhaul effort

## Some systems must be able to operate "offline"

- For example, my laptop regularly will not have access to a network
- Provisioning this type of system is challenging while managing configuration drift
- Should maintain a local cache of the secrets it needs -- secret drift is reconciled opportunistically when it has network access
  - Requires the "offline" device to have an additional layer of attestation before decrypting -- likely a password + TPM2 attested unlock

## Defense-in-Depth

- Hosts should be accessible via SSH over a Wireguard tunnel
  - If a error/bug is found in SSH that shouldn't mean an attacker gets _immediate_ access to a system -- they also have to be connected to the system via Wireguard
  - This allows Wireguard to cover for SSH and SSH to cover for Wireguard -- requires _both_ resources to be compromised before an attacker can gain access
- Exception: SSH into a host should drop into a root shell by default -- this is a usability trade-off I accept
  - Since this trade-off is being made -- to at least provide a bit more security if Wireguard and SSH both fail, **_require_** a log of the originating identity to at least audit these log ins
