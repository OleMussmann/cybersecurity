# Temporarily Overwrite `/etc/hosts`

Create a mount bind to temporarily shadow `/etc/hosts` with your own version.
This is less intrusive than writing to the file itself.

## Usage

0. Sanity check: read the content of `temp_hosts.sh` and make sure you understand it.
1. Edit the `./hosts` file. Add the content of your original `/etc/hosts` if necessary.
2. Start the script with sudo `sudo ./temp_hosts.sh`.
3. Press any key to restore the original `/etc/hosts` file.

N.B.: Reboot or execute `sudo umount -f /etc/hosts` by hand if this script would ever fail.
