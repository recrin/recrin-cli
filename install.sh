#! /usr/bin/env bash
# TODO(add support for another target)

if ! command -v curl &>/dev/null; then
  echo "curl not installed. Please install curl."
  exit
elif ! command -v sed &>/dev/null; then
  echo "sed not installed. Please install sed."
  exit
fi

REPO_URL="https://github.com/recrin/recrin-cli"
LATEST_RELEASE_URL="https://api.github.com/repos/recrin/recrin-cli/releases/latest"
# shellcheck disable=SC2001
LATEST_VERSION=$(curl $LATEST_RELEASE_URL -s | grep -o '"tag_name": *"[^"]*"' | cut -d '"' -f 4)

_install_binary() {
  echo "Installing pre-built binary..."

  case "$OSTYPE" in
  linux*)
    arch=$(uname -m)
    case "$arch" in
    x86_64) target="Linux_x86_64" ;;
    arm64) target="Linux_arm64" ;;
    i386) target="Linux_i386 " ;;
    *)
      echo "Unsupported architecture: $arch"
      exit 1
      ;;
    esac
    ;;
  darwin*)
    arch=$(uname -m)
    case "$arch" in
    x86_64) target="Darwin_x86_64" ;;
    arm64) target="Darwin_arm64" ;;
    *)
      echo "Unsupported architecture: $arch"
      exit 1
      ;;
    esac
    ;;

  *)
    echo "Unsupported operating system: $OSTYPE"
    exit 1
    ;;
  esac

  echo "Target to install: $target"

  EXTENSION="tar.gz"

  FILE_NAME="recrin-cli_$target.$EXTENSION"

  temp_dir=$(mktemp -d)
  pushd "$temp_dir" >/dev/null || exit 1
  curl -LO "$REPO_URL/releases/download/$LATEST_VERSION/$FILE_NAME"
  mkdir $target && tar -xzf $FILE_NAME -C $target
  # tar -xzf "test-release_Darwin_x86_64.tar.gz"
  echo "Installing to $HOME/.recrin/bin/recrin"
  mkdir -p "$HOME/.recrin/bin/" && mv "$target/recrin" "$HOME/.recrin/bin/"
  popd >/dev/null || exit 1
  if [[ ":$PATH:" != *":$HOME/.recrin/bin:"* ]]; then
    echo "Add $HOME/.recrin/bin to PATH to run recrin"
  fi
}

_install_binary
