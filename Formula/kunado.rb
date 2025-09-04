class Kunado < Formula
  desc "Rails development gateway for HTTPS access to multiple apps"
  homepage "https://github.com/komagata/kunado"
  url "https://github.com/komagata/kunado/archive/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on "docker"
  depends_on "ruby"

  def install
    bin.install "kunado"
    
    # Create necessary directories
    (var/"kunado").mkpath
    (var/"kunado/routes").mkpath
    (var/"kunado/certs").mkpath
    (var/"kunado/registry.json").write("{}")
  end

  service do
    run [opt_bin/"kunado", "proxy", "up"]
    run_type :immediate
    keep_alive true
    log_path var/"log/kunado.log"
    error_log_path var/"log/kunado.error.log"
    environment_variables PATH: std_service_path_env, KUNADO_SERVICE: "true"
  end

  def post_install
    ohai "To start kunado automatically at login:"
    ohai "  brew services start kunado"
    ohai ""
    ohai "To start kunado manually:"
    ohai "  kunado proxy up"
    ohai ""
    ohai "Don't forget to add the hook to your shell configuration:"
    ohai "  echo 'eval \"$(kunado hook)\"' >> ~/.zshrc"
  end

  test do
    assert_match "kunado #{version}", shell_output("#{bin}/kunado version")
  end
end