download_node() {
  local node_url="http://s3pository.heroku.com/node/v$node_version/node-v$node_version-linux-x64.tar.gz"
  cached_node="${cache_dir}/node-v$node_version-linux-x64.tar.gz"

  if [ ! -f ${cached_node} ]; then
    info "Downloading node $node_version..."
    curl $node_url -s -o
  else
    info "Using cached node $node_version..."
  fi
}

install_node() {
  info "Installing node $node_version..."
  tar $cached_node xzf - -C /tmp

  # Move node (and npm) into .heroku/node and make them executable
  mv /tmp/node-v$node_version-linux-x64/* $heroku_dir/node
  chmod +x $heroku_dir/node/bin/*
  PATH=$heroku_dir/node/bin:$PATH
}

install_npm() {
  # Optionally bootstrap a different npm version
  if [[ `npm --version` == "$npm_version" ]]; then
    info "npm `npm --version` already installed with node"
  else
    info "Downloading and installing npm $npm_version (replacing version `npm --version`)..."
    npm install --unsafe-perm --quiet -g npm@$npm_version 2>&1 >/dev/null | indent
  fi
}
