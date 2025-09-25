# Temporarily Overwrite `/etc/resolv.conf`

Create a mount bind to temporarily shadow `/etc/resolv.conf` with your own version.
This is less intrusive than writing to the file itself.

## Usage

0. Sanity check: read the content of `temp_dns.sh` and make sure you understand it.
1. Edit the `./resolv.conf` file. Add the content of your original `/etc/resolv.conf` if necessary.
2. Start the script with sudo `sudo ./temp_dns.sh`.
3. Press any key to restore the original `/etc/resolv.conf` file.

N.B.: Reboot or execute `sudo umount -f /etc/resolv.conf` by hand if this script would ever fail.
