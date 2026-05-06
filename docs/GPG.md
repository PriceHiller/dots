# Editing a GPG Key

This should also work for a GPG in a card that has the `[C]` (**C**ertify) flag.

> [!IMPORTANT]
>
> The `$GNUPGHOME/pubring.kbx` file needs to be writeable by the current user. If it is symlinked in from the Nix store, copy its contents and remove the symlink. If it isn't writeable, you will see "permission denied" errors from gpg when you issue the `save` command.

1. List out the available keys (note you'll need the actual private key available)

   ```
   > gpg --list-secret-keys

   /home/price/.local/share/gnupg/pubring.kbx
   ------------------------------------------
   sec   ed25519/0xC3FADDE7A8534BEB 2024-02-13 [SC]
         Key fingerprint = 60F8 5CAB C887 3D29 7309  88FD C3FA DDE7 A853 4BEB
   uid                   [ultimate] Price Hiller <price@pricehiller.com>
   uid                   [ultimate] Price Hiller <price@price-hiller.com>
   ssb   cv25519/0x98B7CBA286CB21C7 2024-02-13 [E]
   ssb   ed25519/0x5ABC7A4615993C90 2024-02-13 [A]
   ssb#  ed25519/0x29F848DD097F39EC 2024-02-13 [S]
   ```

   If this command fails, it's likely the secret keys aren't available. You'll need to import them via `gpg --import ./secrey-key-file`.

   Choose the key we want to edit, in this case I want to edit the master key (`sec`), not the sub key, so I'll choose `0xC3FADDE7A8534BEB`. Alternatively, you could use the keygrip (which should be tab completed), see `gpg --list-secret-keys --with-keygrip`

2. Now edit the key:

   ```
   > gpg --edit-key 0xC3FADDE7A8534BEB
   ```

   Do any actions you need in the GPG cli (e.g. revoking a user id) and then save via the `save` command.

3. Ensure you send the updated keys to keyservers via `gpg --send-keys 0xC3FADDE7A8534BEB`
4. Update the `gpg-wkd` public key we deploy for automatic key discovery
   1. Get the `wks` url via `gpg-wks-client --print-wkd-url <uid-here>`, so for example:

      ```
      > gpg-wks-client --print-wkd-url price@pricehiller.com
      https://openpgpkey.pricehiller.com/.well-known/openpgpkey/pricehiller.com/hu/rnmhgp3dsaq8hjgu49j8oongugr5cg4j?l=price
      ```

      Note the string after `/hu/`, the last part (file part) of the url. It is `rnmhgp3dsaq8hjgu49j8oongugr5cg4j` in this case. That will be the file name that we write the public key to for a webserver to serve for the uid's domain.

      In this case the domain is `pricehiller.com`.

   2. Export that public key to the wks hash via `gpg --export --no-armor <handle-here> > <wks-hash>`, so for example:

      ```
      > gpg --export --no-armor 0xC3FADDE7A8534BEB > rnmhgp3dsaq8hjgu49j8oongugr5cg4j
      ```

      and then copy that file to where the webserver (at the time of writing `Nginx`) can serve it from that `.well-known/openpgpkey/hu/<key-file-here>`.

      So for the wks hash shown earlier, that path would be `.well-known/openpgpkey/hu/rnmhgp3dsaq8hjgu49j8oongugr5cg4j`.
