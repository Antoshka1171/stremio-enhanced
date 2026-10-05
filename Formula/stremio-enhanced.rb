class StremioEnhanced < Formula
  desc "Electron-based Stremio client with plugins and themes support"
  homepage "https://github.com/REVENGE977/stremio-enhanced"
  url "https://github.com/REVENGE977/stremio-enhanced/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "67f215829ca7262a259e825befad5672bebf6aa00652574a2a6da5fcb6dd5de1"
  license "MIT"

  depends_on "python@3.14" => :build
  depends_on "node"

  def install
    # Keep this aligned with the build-from-source instructions in README.md.
    system "npm", "install", *std_npm_args(prefix: false, ignore_scripts: false)

    if OS.mac?
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
      if Hardware::CPU.arm?
        system "npm", "run", "build:linux:arm64"
        unpacked_dir = buildpath/"release-builds/linux-arm64-unpacked"
      else
        system "npm", "run", "build:linux:x64"
        unpacked_dir = buildpath/"release-builds/linux-unpacked"
      end

      libexec.install Dir["#{unpacked_dir}/*"]
      bin.write_exec_script libexec/"stremio-enhanced"

      applications_dir = share/"applications"
      applications_dir.mkpath
      (applications_dir/"stremio-enhanced.desktop").write <<~DESKTOP
        [Desktop Entry]
        Type=Application
        Name=Stremio Enhanced
        Comment=Electron-based Stremio client with plugins and themes support
        Exec=stremio-enhanced
        Icon=stremio-enhanced
        Categories=AudioVideo;Video;
        Terminal=false
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
