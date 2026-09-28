class Pandora < Formula
  desc "A scheduler that routes a repository's heavy commands off the machine agents type on"
  homepage "https://github.com/gbasin/pandora"
  url "https://github.com/gbasin/pandora/releases/download/v0.3.6/pandora-0.3.6.tar.gz"
  sha256 "982540051152bc5220541cab5dd429babe0f8de14003c1b9b4c9acd813e140bb"
  license "MIT"

  depends_on "python@3.13"

  def install
    # Pandora activates itself: `pandora upgrade` snapshots a tree into
    # ~/.local/share/pandora/versions and runs it through `current`. The tree
    # lives in libexec so bin/pandora resolves its package next to it; the
    # wrappers only pin the interpreter, since brewed pythons are keg-only
    # and /usr/bin/python3 predates tomllib.
    libexec.install Dir["*"]
    env = {
      "PANDORA_HOME"   => libexec,
      "PANDORA_PYTHON" => Formula["python@3.13"].opt_bin/"python3.13",
    }
    (bin/"pandora").write_env_script libexec/"bin"/"pandora", env
    (bin/"pnpm").write_env_script libexec/"bin"/"pnpm", env
  end

  def caveats
    <<~EOS
      Activate the install (fetches the latest release, restarts the daemon
      after a drain):
        pandora upgrade
      Then link the launchers first on PATH:
        mkdir -p ~/.local/bin
        ln -s ~/.local/share/pandora/current/bin/pandora ~/.local/bin/pandora
        ln -s ~/.local/share/pandora/current/bin/pnpm ~/.local/bin/pnpm
        touch ~/.local/bin/.pandora-shim
    EOS
  end

  test do
    assert_equal "pandora #{version}", shell_output("#{bin}/pandora --version").strip
  end
end
