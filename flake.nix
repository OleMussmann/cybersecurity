{
  description = "cybersecurity";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        system = "${system}";
        config.allowUnfree = true;  # allow for unfree burpsuite
      };

      # Ugly hack for evil-winrm, see https://github.com/NixOS/nixpkgs/issues/255276
      openssl_conf = pkgs.writeText "openssl.conf" ''
        openssl_conf = openssl_init

        [openssl_init]
        providers = provider_sect

        [provider_sect]
        default = default_sect
        legacy = legacy_sect

        [default_sect]
        activate = 1

        [legacy_sect]
        activate = 1
      '';
    in {
      devShells.default = pkgs.mkShell rec {
        packages = with pkgs; [
          amass
          awscli
          burpsuite
          dirb
          dnsrecon
          evil-winrm
          exploitdb
          ffuf
          gobuster
          inetutils
          knockpy
          john
          mariadb
          metasploit
          netcat-gnu
          nftables
          ngrep
          nikto
          nmap
          openvpn
          postgresql  # for metasploit
          redis
          responder
          samba
          socat
          sqlmap
          subfinder
          termshark
          wordlists
          wfuzz
          wireshark
        ];

        # Ugly hack for evil-winrm, see https://github.com/NixOS/nixpkgs/issues/255276
        OPENSSL_CONF="${openssl_conf}";
      };
    });
}
