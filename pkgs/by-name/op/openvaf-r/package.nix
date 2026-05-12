{
  lib,
  rustPlatform,
  fetchFromGitHub,
  llvmPackages_21,
  libxml2,
  ncurses,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "openvaf-r";
  version = "0-unstable-2026-02-24";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "arpadbuermen";
    repo = "OpenVAF";
    rev = "2e066436d985b05cf8e6563e936daf9ab875775a";
    hash = "sha256-AXtp8qaDq/MRYz2TYXRwT3kS+8EnKyakD3lQwdv3K34=";
  };

  cargoHash = "sha256-PchAbZN2a3mUMt3UUt7QiihoWSn8xBzg7w/v/7LWv2Q=";

  stdenv = llvmPackages_21.stdenv;

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    llvmPackages_21.llvm
    llvmPackages_21.clang-unwrapped
  ];

  buildInputs = [
    libxml2
    ncurses
    zlib
  ];

  buildFeatures = [ "llvm21" ];

  cargoBuildFlags = [
    "--package"
    "openvaf-driver"
  ];

  cargoTestFlags = [
    "--package"
    "openvaf-driver"
  ];

  env = {
    LLVM_SYS_211_PREFIX = "${llvmPackages_21.llvm.dev}";
  };

  postPatch = ''
    substituteInPlace openvaf/osdi/build.rs \
      --replace-fail "-fPIC" ""
    substituteInPlace openvaf/target/build.rs \
      --replace-fail 'gen_msvcrt_importlib(&sh, "x64", "x86_64", check)' \
                     'gen_msvcrt_importlib(&sh, "x64", "x86_64", true)' \
      --replace-fail 'gen_msvcrt_importlib(&sh, "arm64", "aarch64", check)' \
                     'gen_msvcrt_importlib(&sh, "arm64", "aarch64", true)' \
      --replace-fail 'gen_msys2_importlib(&sh, "x64", "x86_64", check)' \
                     'gen_msys2_importlib(&sh, "x64", "x86_64", true)' \
      --replace-fail 'gen_msys2_importlib(&sh, "arm64", "aarch64", check)' \
                     'gen_msys2_importlib(&sh, "arm64", "aarch64", true)'
  '';

  hardeningDisable = [ "pic" ];

  meta = {
    description = "Verilog-A compiler producing OSDI 0.4 compact device models (arpadbuermen fork)";
    homepage = "https://github.com/arpadbuermen/OpenVAF";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sophronesis ];
    platforms = lib.platforms.linux;
    mainProgram = "openvaf-r";
  };
})
