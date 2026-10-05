class StremioEnhanced < Formula
  desc "Electron-based Stremio client with plugins and themes support"
  homepage "https://github.com/REVENGE977/stremio-enhanced"
  url "https://github.com/REVENGE977/stremio-enhanced/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "67f215829ca7262a259e825befad5672bebf6aa00652574a2a6da5fcb6dd5de1"
  license "MIT"
  revision 2

  on_macos do
    depends_on "python@3.14" => :build
    depends_on "node"
  end

  on_linux do
    resource "appimage" do
      if Hardware::CPU.arm?
        url "https://github.com/REVENGE977/stremio-enhanced/releases/download/v1.2.0/Stremio.Enhanced-1.2.0-arm64.AppImage"
        sha256 "71e455afba897c58cd590ac9b4e57a5cbb3c2294e382d409d420c25dd55dd683"
      else
        url "https://github.com/REVENGE977/stremio-enhanced/releases/download/v1.2.0/Stremio.Enhanced-1.2.0.AppImage"
        sha256 "6be927c60feb77921e7784552bc1a0ef1785125a2f25a6f482ac698ecd757c05"
      end
    end

    resource "icon" do
      url "https://raw.githubusercontent.com/REVENGE977/stremio-enhanced/v1.2.0/images/icon.png"
      sha256 "261a3512b3cceb113d810ddf4f6b1b9c5d6b93810dac8c2b25aea1d26dfae412"
    end
  end

  def install
    if OS.mac?
      # Keep this aligned with the build-from-source instructions in README.md.
      system "npm", "install", *std_npm_args(prefix: false, ignore_scripts: false)

      if Hardware::CPU.arm?
        system "npm", "run", "build:mac:arm64"
        app_bundle = buildpath/"release-builds/mac-arm64/Stremio Enhanced.app"
      else
        system "npm", "run", "build:mac:x64"
        app_bundle = buildpath/"release-builds/mac/Stremio Enhanced.app"
      end

      prefix.install app_bundle
      bin.write_exec_script prefix/"Stremio Enhanced.app/Contents/MacOS/Stremio Enhanced"
    elsif OS.linux?
      resource("appimage").stage do
        appimage = Dir["*.AppImage"].first
        libexec.install appimage => "stremio-enhanced.AppImage"
      end
      (bin/"stremio-enhanced").write_env_script libexec/"stremio-enhanced.AppImage", APPIMAGE_EXTRACT_AND_RUN: "1"

      applications_dir = share/"applications"
      applications_dir.mkpath
      (applications_dir/"stremio-enhanced.desktop").write <<~DESKTOP
        [Desktop Entry]
        Type=Application
        Name=Stremio Enhanced
        Comment=Electron-based Stremio client with plugins and themes support
        Exec=#{opt_bin}/stremio-enhanced
        Icon=#{opt_prefix}/share/icons/hicolor/1024x1024/apps/stremio-enhanced.png
        Categories=AudioVideo;Video;
        Terminal=false
        StartupWMClass=stremio-enhanced
      DESKTOP

      icon_dir = share/"icons/hicolor/1024x1024/apps"
      icon_dir.mkpath
      resource("icon").stage { icon_dir.install "icon.png" => "stremio-enhanced.png" }
    else
      odie "Stremio Enhanced is supported only on macOS and Linux"
    end
  end

  def caveats
    <<~EOS
      Playback requires Stremio Service or the app-managed server.js backend.
      Launch Stremio Enhanced once to complete streaming-server setup.

      On Linux, link the desktop entry if your desktop environment does not
      discover Homebrew's shared applications directory automatically:
        mkdir -p ~/.local/share/applications
        ln -sf #{opt_prefix}/share/applications/stremio-enhanced.desktop ~/.local/share/applications/stremio-enhanced.desktop
    EOS
  end

  test do
    assert_predicate bin/"stremio-enhanced", :executable?
  end
end
