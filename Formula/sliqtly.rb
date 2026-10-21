# Written by .github/workflows/update.yml from
# https://firebasestorage.googleapis.com/v0/b/sliqtly.firebasestorage.app/o/downloads%2Fpersonal%2Flatest.json?alt=media
# Do not edit by hand.
class Sliqtly < Formula
  desc "MCP server and presentation viewer: your AI agent makes slides"
  homepage "https://sliqtly.com/local.html"
  version "0.0.21"
  # Sliqtly Personal License: free for personal use and qualifying solo
  # businesses (annual gross revenue below EUR 200,000); other commercial
  # use needs a commercial license. Not open source.
  license :cannot_represent

  on_arm do
    url "https://firebasestorage.googleapis.com/v0/b/sliqtly.firebasestorage.app/o/downloads%2Fpersonal%2Fsliqtly-personal_0.0.21_darwin_arm64.tar.gz?alt=media"
    sha256 "324830a36f3ef8819fd0033250033776932b71c232e910a86c5be62418d91065"
  end
  on_intel do
    url "https://firebasestorage.googleapis.com/v0/b/sliqtly.firebasestorage.app/o/downloads%2Fpersonal%2Fsliqtly-personal_0.0.21_darwin_amd64.tar.gz?alt=media"
    sha256 "2817a9f70cd40a6252fcd7fadbdbda3c504d8355e25a67214f6b3768b00ac052"
  end

  depends_on :macos

  def install
    bin.install "sliqtly-server"
    pkgshare.install "sliqtly.env"
    prefix.install "LICENSE"
    # the service reads its settings from etc/sliqtly/sliqtly.env
    (bin/"sliqtly-service").write <<~SH
      #!/bin/sh
      set -a
      [ -f "#{etc}/sliqtly/sliqtly.env" ] && . "#{etc}/sliqtly/sliqtly.env"
      set +a
      : "${SLIQTLY_DATA:=#{var}/sliqtly}"
      : "${SLIQTLY_BACKUP=#{var}/sliqtly-backup}"
      : "${SLIQTLY_LISTEN:=local}"
      export SLIQTLY_DATA SLIQTLY_BACKUP SLIQTLY_LISTEN
      mkdir -p "$SLIQTLY_DATA"
      exec "#{opt_bin}/sliqtly-server" "$@"
    SH
    chmod 0755, bin/"sliqtly-service"
  end

  def post_install
    (etc/"sliqtly").mkpath
    # kept over upgrades: only written when there is none yet
    cp pkgshare/"sliqtly.env", etc/"sliqtly/sliqtly.env" unless (etc/"sliqtly/sliqtly.env").exist?
    (var/"sliqtly").mkpath
    (var/"log").mkpath
  end

  service do
    run [opt_bin/"sliqtly-service"]
    keep_alive true
    log_path var/"log/sliqtly.log"
    error_log_path var/"log/sliqtly.log"
  end

  def caveats
    <<~EOS
      Start it, now and at every login:
        brew services start sliqtly
      Then open http://localhost:8080/ and connect your agent to
      http://localhost:8080/mcp (https://sliqtly.com/local.html).
      Settings (port, who can connect): #{etc}/sliqtly/sliqtly.env
      License: #{opt_prefix}/LICENSE
    EOS
  end

  test do
    assert_predicate bin/"sliqtly-server", :executable?
  end
end
