#!/bin/sh
set -e

# Kunado installer for Linux
KUNADO_VERSION="0.1.0"
INSTALL_DIR="$HOME/.local/bin"
KUNADO_DIR="$HOME/.kunado"
GITHUB_REPO="komagata/kunado"
KUNADO_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/kunado"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_error() {
    echo "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo "$1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker is not installed"
        print_info "Please install Docker first: https://docs.docker.com/engine/install/"
        exit 1
    fi
    
    if ! docker ps >/dev/null 2>&1; then
        print_error "Docker is not running or you don't have permissions"
        print_info "Please make sure Docker is running and you have the necessary permissions"
        print_info "You may need to add your user to the docker group:"
        print_info "  sudo usermod -aG docker \$USER"
        print_info "  Then log out and back in"
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Check if Ruby is installed
check_ruby() {
    if ! command -v ruby >/dev/null 2>&1; then
        print_error "Ruby is not installed"
        print_info "Please install Ruby first. You can use:"
        print_info "  - Your system package manager (apt, yum, etc.)"
        print_info "  - rbenv: https://github.com/rbenv/rbenv"
        print_info "  - rvm: https://rvm.io/"
        exit 1
    fi
    
    ruby_version=$(ruby -v | cut -d' ' -f2)
    print_success "Ruby ${ruby_version} is installed"
}

# Create necessary directories
create_directories() {
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$KUNADO_DIR"
    mkdir -p "$KUNADO_DIR/routes"
    mkdir -p "$KUNADO_DIR/certs"
    
    if [ ! -f "$KUNADO_DIR/registry.json" ]; then
        echo '{}' > "$KUNADO_DIR/registry.json"
    fi
    
    print_success "Created Kunado directories"
}

# Download and install Kunado
install_kunado() {
    print_info "Downloading Kunado..."
    
    # Download with curl or wget
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$KUNADO_URL" -o "$INSTALL_DIR/kunado.tmp"; then
            print_error "Failed to download Kunado"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q "$KUNADO_URL" -O "$INSTALL_DIR/kunado.tmp"; then
            print_error "Failed to download Kunado"
            exit 1
        fi
    else
        print_error "Neither curl nor wget is installed"
        print_info "Please install curl or wget and try again"
        exit 1
    fi
    
    # TODO: Add SHA256 verification here when checksums are published
    # expected_sha256="..."
    # actual_sha256=$(sha256sum "$INSTALL_DIR/kunado.tmp" | cut -d' ' -f1)
    # if [ "$expected_sha256" != "$actual_sha256" ]; then
    #     print_error "SHA256 checksum verification failed"
    #     rm -f "$INSTALL_DIR/kunado.tmp"
    #     exit 1
    # fi
    
    # Move to final location and make executable
    mv "$INSTALL_DIR/kunado.tmp" "$INSTALL_DIR/kunado"
    chmod +x "$INSTALL_DIR/kunado"
    
    print_success "Kunado installed to $INSTALL_DIR/kunado"
}

# Check if PATH includes install directory
check_path() {
    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        print_warning "$INSTALL_DIR is not in your PATH"
        print_info ""
        print_info "Add Kunado to your PATH by adding this line to your shell configuration:"
        
        if [ -f "$HOME/.bashrc" ]; then
            print_info "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
        elif [ -f "$HOME/.zshrc" ]; then
            print_info "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
        else
            print_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
        
        print_info ""
        print_info "Then reload your shell configuration:"
        print_info "  exec \$SHELL"
        print_info ""
        
        # Set flag to show different next steps
        PATH_WARNING=1
    else
        print_success "$INSTALL_DIR is in PATH"
    fi
}

# Print next steps
print_next_steps() {
    print_info ""
    print_success "Kunado ${KUNADO_VERSION} has been installed successfully!"
    print_info ""
    print_info "Next steps:"
    
    if [ -n "$PATH_WARNING" ]; then
        print_info "1. Add ~/.local/bin to your PATH (see instructions above)"
        print_info "2. Start the proxy:"
        print_info "   ~/.local/bin/kunado proxy up"
        print_info "3. Add the Kunado hook to your shell configuration:"
        print_info "   echo 'eval \"\$(~/.local/bin/kunado hook)\"' >> ~/.bashrc"
        print_info "4. Reload your shell:"
        print_info "   exec \$SHELL"
    else
        print_info "1. Start the proxy:"
        print_info "   kunado proxy up"
        print_info "2. Add the Kunado hook to your shell configuration:"
        print_info "   echo 'eval \"\$(kunado hook)\"' >> ~/.bashrc"
        print_info "3. Reload your shell:"
        print_info "   exec \$SHELL"
    fi
    
    print_info ""
    print_info "Then, in your Rails project directory:"
    print_info "  kunado add       # Register the app"
    print_info "  bin/rails s      # Start Rails server"
    print_info "  kunado open      # Open in browser"
    print_info ""
    print_info "For more information, run: kunado help"
}

# Main installation flow
main() {
    echo "Installing Kunado - Rails Development Gateway"
    echo "=============================================="
    echo ""
    
    # Run checks
    check_docker
    check_ruby
    
    # Install
    create_directories
    install_kunado
    check_path
    
    # Show next steps
    print_next_steps
}

# Run main function
main