# Kunado

Rails development gateway that enables HTTPS access to multiple Rails apps via `https://{app}.localhost`.

> **Name Origin**: Kunado (岐) is an ancient Japanese word meaning "crossroads" or "where paths diverge" - fitting for a tool that routes requests to different Rails applications.

## Features

- 🔒 Automatic HTTPS with local certificates
- 🚀 Zero-config for Rails developers
- 🎯 No need to manage port numbers - each app gets a unique port automatically
- 📦 Run multiple Rails apps simultaneously without port conflicts
- 🔧 Simple CLI interface
- 🐳 Docker-based proxy (Traefik)

## Requirements

- Ruby (stdlib only, no gems required)
- Docker
- macOS or Linux

## Installation

### macOS (Homebrew)

```bash
brew install kunado
```

#### Auto-start on macOS

To automatically start Kunado when your Mac boots:

```bash
# Start Kunado service and enable auto-start
brew services start kunado

# Stop auto-start
brew services stop kunado

# Check service status
brew services list | grep kunado
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/komagata/kunado/main/install.sh | sh
```

## Quick Start

1. **Initial Setup**
```bash
# macOS with auto-start
brew services start kunado

# OR manually start the proxy
kunado proxy up

# Add hook to shell configuration
echo 'eval "$(kunado hook)"' >> ~/.zshrc  # or ~/.bashrc
exec $SHELL
```

2. **Per Rails Project**
```bash
cd my-rails-app
kunado add          # Register the app
bin/rails s         # Start Rails (PORT is set automatically)
kunado open         # Open https://my-rails-app.localhost
```

## Commands

- `kunado proxy up` - Start the proxy server
- `kunado proxy down` - Stop the proxy server
- `kunado proxy status` - Show proxy status
- `kunado add` - Register current directory as an app
- `kunado delete` - Remove current app from registry
- `kunado list` - List all registered apps
- `kunado open` - Open current app in browser
- `kunado hook` - Print environment variables for current app
- `kunado version` - Show version
- `kunado help` - Show help

## How It Works

1. **Proxy Management**: Kunado manages a Traefik container that listens on ports 80/443
2. **Certificate Generation**: Creates a local CA and wildcard certificate for `*.localhost`
3. **App Registration**: Each Rails app gets a unique port (3000-8999) based on its name
4. **Environment Variables**: Sets `APP_NAME`, `APP_HOST`, and `PORT` via shell hook
5. **Automatic Routing**: Traefik routes `https://{app}.localhost` to the correct port

## File Locations

- `~/.kunado/` - Main configuration directory
- `~/.kunado/routes/` - Traefik route configurations
- `~/.kunado/certs/` - Local CA and certificates
- `~/.kunado/registry.json` - App registry

## Security

- Certificates are stored in user's home directory with 0600 permissions
- Local CA is only trusted for `*.localhost` domains
- All traffic stays local

## License

MIT