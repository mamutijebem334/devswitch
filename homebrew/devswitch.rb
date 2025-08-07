class Devswitch < Formula
  desc "Instantly switch developer profiles (.gitconfig, shell rc, VSCode settings) across work/school/personal setups"
  homepage "https://github.com/GustyCube/devswitch"
  version "1.0.0"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/GustyCube/devswitch/releases/download/v1.0.0/devswitch-darwin-arm64"
      sha256 "REPLACE_WITH_ACTUAL_SHA256_FOR_ARM64"
    else
      url "https://github.com/GustyCube/devswitch/releases/download/v1.0.0/devswitch-darwin-amd64"
      sha256 "REPLACE_WITH_ACTUAL_SHA256_FOR_AMD64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/GustyCube/devswitch/releases/download/v1.0.0/devswitch-linux-arm64"
      sha256 "REPLACE_WITH_ACTUAL_SHA256_FOR_LINUX_ARM64"
    else
      url "https://github.com/GustyCube/devswitch/releases/download/v1.0.0/devswitch-linux-amd64"
      sha256 "REPLACE_WITH_ACTUAL_SHA256_FOR_LINUX_AMD64"
    end
  end

  def install
    bin.install "devswitch-darwin-arm64" => "devswitch" if Hardware::CPU.arm? && OS.mac?
    bin.install "devswitch-darwin-amd64" => "devswitch" if Hardware::CPU.intel? && OS.mac?
    bin.install "devswitch-linux-arm64" => "devswitch" if Hardware::CPU.arm? && OS.linux?
    bin.install "devswitch-linux-amd64" => "devswitch" if Hardware::CPU.intel? && OS.linux?
  end

  test do
    system "#{bin}/devswitch", "--version"
  end
end