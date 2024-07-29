{
  description = "cybersecurity";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        system = "${system}";
        config.allowUnfree = true;  # allow for unfree cuda
      };
    in {
      devShells.default = pkgs.mkShell rec {
        packages = with pkgs; [
          burpsuite
          dirb
          inetutils
          john
          metasploit
          netcat
          nikto
          nmap
          openvpn
          redis
          samba
          sqlmap
          wireshark
        ];
      };
    });
}
