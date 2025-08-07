class Devswitch < Formula
  desc "Instantly switch developer profiles (.gitconfig, shell rc, VSCode settings) across work/school/personal setups"
  homepage "https://github.com/GustyCube/devswitch"
  version "0.1.0"
  
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/GustyCube/devswitch/releases/download/v1.0.0/devswitch-darwin-arm64"
      sha256 "a5a5fa4397f868d41e03a59062a94bcd88fe26c568361eaea7a850ce4a729c33"
    else
      url "https://github.com/GustyCube/devswitch/releases/download/v1.0.0/devswitch-darwin-amd64"
      sha256 "298761516b9c3ee4d01aff240d5f7dd95defc20115281a3f378ef067d7952e78"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/GustyCube/devswitch/releases/download/v1.0.0/devswitch-linux-arm64"
      sha256 "9c8b7211f47417d0d55ce4416d929dd1da0a85e3eb08efd27528deaa32cc1ec3"
    else
      url "https://github.com/GustyCube/devswitch/releases/download/v1.0.0/devswitch-linux-amd64"
      sha256 "1fd51d73d0e816afb7f7d22beb6c72cd6fcc3cbef4a6184301900b6f93180638"
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