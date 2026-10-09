class StremioEnhanced < Formula
  RELEASE_VERSION = "1.2.0".freeze
  RELEASE_TAG = "v#{RELEASE_VERSION}".freeze

  desc "Electron-based Stremio client with plugins and themes support"
  homepage "https://github.com/REVENGE977/stremio-enhanced"
  url "https://github.com/REVENGE977/stremio-enhanced/archive/refs/tags/#{RELEASE_TAG}.tar.gz"
  sha256 "67f215829ca7262a259e825befad5672bebf6aa00652574a2a6da5fcb6dd5de1"
  license "MIT"
  revision 2

  # Update RELEASE_VERSION, the source checksum, and the platform archive
  # checksums together when publishing a new release.
  resource "release" do
    on_macos do
      if Hardware::CPU.arm?
        url "https://github.com/REVENGE977/stremio-enhanced/releases/download/#{RELEASE_TAG}/mac-arm64.zip"
        sha256 "94d87af7ebd2424b8e8285de0fa7e869781a2c5956b35cc7989af8a3055d7cbf"
      else
        url "https://github.com/REVENGE977/stremio-enhanced/releases/download/#{RELEASE_TAG}/mac-unpacked.zip"
        sha256 "9d86eadb3166d6e30ff8dbba4c55d7cea8e957ee1b6fd91e3962be6db53c75ee"
      end
    end

    on_linux do
      if Hardware::CPU.arm?
        url "https://github.com/REVENGE977/stremio-enhanced/releases/download/#{RELEASE_TAG}/linux-arm64-unpacked.zip"
        sha256 "5b69b1729f9545e9a79d01c15a205a15c48bf17bf2201fb589ca24026a60fa7f"
      else
        url "https://github.com/REVENGE977/stremio-enhanced/releases/download/#{RELEASE_TAG}/linux-unpacked.zip"
        sha256 "b11ccede96c9387201783e225f21f140c500216233ee69789ff006b919fa7342"
      end
    end
  end

  def install
    if OS.mac?
      resource("release").stage do
        app_bundle = Dir["**/Stremio Enhanced.app"].first
        odie "Release archive does not contain Stremio Enhanced.app" unless app_bundle
        prefix.install app_bundle
      end
      bin.write_exec_script prefix/"Stremio Enhanced.app/Contents/MacOS/Stremio Enhanced"
    elsif OS.linux?
      resource("release").stage do
        unless File.executable?("stremio-enhanced")
          odie "Release archive does not contain the Stremio Enhanced executable"
        end
        libexec.install Dir["*"]
      end
      bin.write_exec_script libexec/"stremio-enhanced"

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
      cp "images/icon.png", icon_dir/"stremio-enhanced.png"
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
