{
  description = "cybersecurity";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        system = "${system}";
        config.allowUnfree = true;  # allow for unfree burpsuite
      };

      user = "alice";

      myPackages = with pkgs; [
        amass
        awscli
        burpsuite
        dirb
        dnsrecon
        evil-winrm
        exploitdb
        ffuf
        freerdp3
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
        seclists
        socat
        sqlmap
        subfinder
        termshark
        unixtools.xxd
        whatweb
        wordlists
        wfuzz
        wireshark
      ];

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
        packages = myPackages;

        # Ugly hack for evil-winrm, see https://github.com/NixOS/nixpkgs/issues/255276
        OPENSSL_CONF="${openssl_conf}";
      };
      packages.nixosConfigurations.cybersec = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ ... }: {
            services.displayManager = {
              autoLogin = {
                enable = true;
                user = "alice";
              };
            };
            services.xserver = {
              enable = true;

              # Enable the GNOME Desktop Environment.
              desktopManager.gnome.enable = true;
              displayManager = {
                gdm.enable = true;
              };

              # Keyboard layout
              xkb = {
                layout = "de";
                variant = "neo";
              };
            };

            console = {
              keyMap = "neo";
            };

            # Define a user account. Don't forget to set a password with ‘passwd’.
            users.users.${user} = {
              isNormalUser = true;
              password = "${user}";
              packages = myPackages;
            };

            virtualisation.vmVariant = {
              # following configuration is added only when building VM with build-vm
              virtualisation = {
                memorySize = 32000;  # in MiB
                cores = 14;
              };
            };

            environment.fileSystem."/home/${user}/CYBERSECURITY".source = ./.;

            system.stateVersion = "24.05";
          })

          #home-manager.nixosModules.home-manager {
          #  home-manager.users.alice = {
          #    home = {
          #      stateVersion = "24.05";
          #      file = {
          #        "CYBERSECURITY" = {
          #          source = ./.;
          #          recursive = false;
          #        };
          #      };
          #    };
          #  };
          #}
        ];
      };
    });
}
