{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./version.json);

  platformMap = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-x64";
    "aarch64-darwin" = "darwin-arm64";
  };

  platform =
    platformMap.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  hash =
    versionData.hashes.${stdenv.hostPlatform.system}
      or (throw "No hash for system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "claude-code";
  version = versionData.version;

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-code-releases/${versionData.version}/${platform}/claude";
    inherit hash;
  };

  dontUnpack = true;
  # Disable all fixup phases that modify ELF binaries — Bun standalone
  # executables embed JS bytecode after the ELF and locate it by offset
  # from the end of the file. Any modification breaks the embedded payload.
  dontStrip = true;
  dontPatchELF = true;

  nativeBuildInputs = lib.optionals stdenv.isLinux [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/libexec/claude
    ${lib.optionalString stdenv.isLinux ''
      makeWrapper $out/libexec/claude $out/bin/claude \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}"
    ''}
    ${lib.optionalString stdenv.isDarwin ''
      ln -s $out/libexec/claude $out/bin/claude
    ''}
    runHook postInstall
  '';

  meta = {
    description = "Anthropic's official CLI for Claude — an agentic coding tool";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    platforms = builtins.attrNames platformMap;
    maintainers = [ ];
  };
}
