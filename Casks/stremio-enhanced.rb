cask "stremio-enhanced" do
  version "1.2.0"

  on_arm do
    sha256 "4a786736c3c107c7c89b856d733e6e1b784d16a9889085c09ca9f79a9baf1f70"

    url "https://github.com/REVENGE977/stremio-enhanced/releases/download/v#{version}/Stremio.Enhanced-#{version}-arm64.dmg"
  end
  on_intel do
    sha256 "67d9a276b7ae4fae321e5d3926bb9bb04a9504dec62971ead8012865b0a1a784"

    url "https://github.com/REVENGE977/stremio-enhanced/releases/download/v#{version}/Stremio.Enhanced-#{version}.dmg"
  end

  name "Stremio Enhanced"
  desc "Electron-based Stremio client with plugins and themes support"
  homepage "https://github.com/REVENGE977/stremio-enhanced"

  depends_on :macos

  app "Stremio Enhanced.app"
end
