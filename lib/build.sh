install_node() {
  # Download node from Heroku's S3 mirror of nodejs.org/dist
  info "Downloading and installing node $node_version..."
  node_url="http://s3pository.heroku.com/node/v$node_version/node-v$node_version-linux-x64.tar.gz"
  curl $node_url -s -o - | tar xzf - -C /tmp

  # Move node (and npm) into .heroku/node and make them executable
  mv /tmp/node-v$node_version-linux-x64/* $heroku_path/node
  chmod +x $heroku_path/node/bin/*
  PATH=$heroku_path/node/bin:$PATH
}
