{
  description = "cybersecurity";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
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

      pyPkgs = pkgs.python312Packages;

      myPackages = with pkgs; [
        amass
        arp-scan
        awscli
        burpsuite
        crunch  # generate word lists
        cyberchef
        dirb
        dnsrecon
        evil-winrm
        exiftool
        exploitdb
        ffuf
        freerdp3
        gobuster
        hash-identifier
        hashcat
        hextazy
        inetutils  # telnet etc.
        knockpy
        john
        jython  # for burp suite plugins
        libgcrypt
        mariadb
        masscan
        metasploit
        netcat-gnu
        nftables
        ngrep
        nikto
        nmap
        openssl
        openvpn
        poppler-utils  # for pdfinfo
        postgresql  # for metasploit
        redis
        remmina
        responder
        rlwrap
        ruby
        samba
        seclists
        snort
        socat
        sqlmap
        subfinder
        thc-hydra
        theharvester  # OSINT
        tshark
        termshark
        unixtools.xxd
        waybackurls
        whatweb
        whois
        wordlists
        wfuzz
        wireshark
        yara
      ];

      pyPackages = with pyPkgs; [
        impacket
        pycryptodome
        requests
        sympy
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
        packages = myPackages ++ pyPackages;

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
              packages = myPackages ++ pyPackages;
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
