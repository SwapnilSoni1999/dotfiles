#!/usr/bin/env bash

# update node to latest lts version
function nvm::update() {
  local -r current_node_version=$(nvm current)
  local -r next_node_version=$(nvm version-remote --lts)
  if [ "$current_node_version" != "$next_node_version" ]; then
    local -r previous_node_version=$current_node_version
    nvm install --lts
    nvm reinstall-packages "$previous_node_version"
    nvm uninstall "$previous_node_version"
    nvm cache clear
  fi
}
