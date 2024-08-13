# Cybersecurity Tools

## Setup
Allow the flake to open an environment with `direnv allow`.

## Metasploit
- Install `postgresql`, add `identMap`
  ```
  # ArbitraryMapName systemUser DBUser
  metasploit         you        msf_user
  ```
- Create user:
  `sudo -u postgres createuser msf_user -P`  
- Create database:
  `sudo -u postgres createdb --owner=msf_user msf_database`  
- Connect metasploit to db
  `db_connect msf_user:SUPERSECRETPASSWORD@127.0.0.1:5432/msf_database`  
- Test connection
  `db_status`  
  -> `Connected to msf_database. Connection type: postgresql. Connection name: local_db_service.`

### Usage Tip
Make sure to set the `LHOST` IP to `tun0`, or the IP that was assigned with the VPN, if necessary.

## Open Ports

- Temporarily open firewall `nixos-firewall-tool open tcp 4444`
- Reset firewall `nixos-firewall-tool reset`
