{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
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

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/claude
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
