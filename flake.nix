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

      responder_patched = (pkgs.responder.overrideAttrs (oldAttrs: rec {
        buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.openssl pkgs.coreutils ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin $out/share/Responder
          cp -R . $out/share/Responder

          makeWrapper ${pkgs.python3.interpreter} $out/bin/responder \
          --set PYTHONPATH "$PYTHONPATH:$out/share/Responder" \
          --add-flags "$out/share/Responder/Responder.py" \
          --run "mkdir -p /var/lib/responder"

          substituteInPlace $out/share/Responder/Responder.conf \
          --replace-quiet "Responder-Session.log" "/var/lib/responder/Responder-Session.log" \
          --replace-quiet "Poisoners-Session.log" "/var/lib/responder/Poisoners-Session.log" \
          --replace-quiet "Analyzer-Session.log" "/var/lib/responder/Analyzer-Session.log" \
          --replace-quiet "Config-Responder.log" "/var/lib/responder/Config-Responder.log" \
          --replace-quiet "Responder.db" "/var/lib/responder/Responder.db"

          runHook postInstall

          runHook postPatch
        '';

        postInstall = ''
          wrapProgram $out/bin/responder \
          --run "mkdir -p /var/lib/responder/certs && ${pkgs.openssl}/bin/openssl genrsa -out /var/lib/responder/certs/responder.key 2048 && ${pkgs.openssl}/bin/openssl req -new -x509 -days 3650 -key /var/lib/responder/certs/responder.key -out /var/lib/responder/certs/responder.crt -subj '/'" \
          --run "mkdir -p /etc/responder && if [ ! -f /etc/responder/Responder.conf ]; then cp $out/share/Responder/Responder.conf /etc/responder/Responder.conf && chmod +w /etc/responder/Responder.conf; fi"
        '';

        postPatch = ''
          if [ -f $out/share/Responder/settings.py ]; then
          substituteInPlace $out/share/Responder/settings.py \
          --replace-quiet "self.LogDir = os.path.join(self.ResponderPATH, 'logs')" "self.LogDir = os.path.join('/var/lib/responder', 'logs')" \
          --replace-quiet "os.path.join(self.ResponderPATH, 'Responder.conf')" "'/etc/responder/Responder.conf'"
          fi

          if [ -f $out/share/Responder/utils.py ]; then
          substituteInPlace $out/share/Responder/utils.py \
          --replace-quiet "logfile = os.path.join(settings.Config.ResponderPATH, 'logs', fname)" "logfile = os.path.join('/var/lib/responder', 'logs', fname)"
          fi

          if [ -f $out/share/Responder/Responder.py ]; then
          substituteInPlace $out/share/Responder/Responder.py \
          --replace-quiet "certs/responder.crt" "/var/lib/responder/certs/responder.crt" \
          --replace-quiet "certs/responder.key" "/var/lib/responder/certs/responder.key"
          fi

          if [ -f $out/share/Responder/Responder.conf ]; then
          substituteInPlace $out/share/Responder/Responder.conf \
          --replace-quiet "certs/responder.crt" "/var/lib/responder/certs/responder.crt" \
          --replace-quiet "certs/responder.key" "/var/lib/responder/certs/responder.key"
          fi
        '';
      }));

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
          ffuf
          gobuster
          inetutils
          knockpy
          john
          mariadb
          metasploit
          netcat
          nftables
          nikto
          nmap
          openvpn
          redis
          samba
          sqlmap
          subfinder
          #wordlists  # currently broken, use `nix shell nixpkgs#wordlists` instead
          #wfuzz  # currently broken, use `nix shell nixpkgs#wfuzz` instead
          wireshark

          # patched packages
          responder_patched
        ];

        # Ugly hack for evil-winrm, see https://github.com/NixOS/nixpkgs/issues/255276
        OPENSSL_CONF="${openssl_conf}";
      };
    });
}
