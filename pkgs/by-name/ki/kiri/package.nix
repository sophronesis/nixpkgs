{
  lib,
  fetchurl,
  stdenvNoCC,
  nix-update-script,
}:

let
  # sha256 of the release tarball per mac arch, from the GitHub release API
  hashAarch64 = "sha256-e+HCiwjy50rC70+JcqPalR+JpONfEKRh3Oyw+tm5SvI=";
  hashX86_64 = "sha256-My0xO6WbKTmwvHaptVrDD2g1N6NOamUlZcfDn4S0Igk=";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kiri";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/libracoder/kiri/releases/download/v${finalAttrs.version}/Kiri-${finalAttrs.version}-${
      if stdenvNoCC.hostPlatform.isAarch64 then "arm64" else "x86_64"
    }.tar.gz";
    hash = if stdenvNoCC.hostPlatform.isAarch64 then hashAarch64 else hashX86_64;
  };

  # the tarball is a signed app bundle: the Kiri binary locates its VM
  # kernel relative to the bundle, so the bundle layout must stay intact.
  sourceRoot = "Kiri.app";

  dontPatchShebangs = true;
  dontFixup = true;

  __structuredAttrs = true;
  strictDeps = true;

  installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications/Kiri.app $out/bin
        cp -R . "$out/Applications/Kiri.app"
        cat > "$out/bin/kiri" <<EOF
    #!/bin/sh
    exec "$out/Applications/Kiri.app/Contents/MacOS/kiri" "\$@"
    EOF
        chmod +x "$out/bin/kiri"
        runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Small, fast container runtime that speaks the Docker Engine API";
    longDescription = ''
      Kiri is a container runtime for macOS that runs Docker images in one
      lightweight Linux VM (Virtualization.framework, custom kernel) and
      speaks the Docker Engine API, so the docker CLI, Compose and buildx
      work unchanged. The runtime requires Kiri's prebuilt custom Linux VM
      kernel and a code-signed app bundle, so it is packaged from the
      upstream release artifact rather than from source.
    '';
    homepage = "https://runkiri.com/";
    changelog = "https://github.com/libracoder/kiri/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sophronesis ];
    mainProgram = "kiri";
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
