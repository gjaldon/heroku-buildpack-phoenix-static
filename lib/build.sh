download_node() {
  local node_url="http://s3pository.heroku.com/node/v$node_version/node-v$node_version-linux-x64.tar.gz"

  if [ ! -f ${cached_node} ]; then
    info "Downloading node ${node_version}..."
    curl -s ${node_url} -o ${cached_node}
    cleanup_old_node
  else
    info "Using cached node ${node_version}..."
  fi
}

cleanup_old_node() {
  local old_node_dir=$cache_dir/node-v$old_node-linux-x64.tar.gz
  if [ "$old_node" != "$node_version" ] && [ -f $old_node_dir ]; then
    info "Cleaning up old node and old dependencies in cache"
    rm $old_node_dir
    rm -rf $cache_dir/node_modules
  fi
}

install_node() {
  info "Installing node $node_version..."
  tar xzf ${cached_node} -C /tmp

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

install_and_cache_deps() {
  info "Installing and caching node modules"
  cd $cache_dir
  cp -f $build_dir/package.json ./

  npm install --quiet --unsafe-perm --userconfig $build_dir/npmrc 2>&1 | indent
  npm rebuild 2>&1 | indent
  npm --unsafe-perm prune 2>&1 | indent
  cp -r node_modules $build_dir
  PATH=$build_dir/node_modules/.bin:$PATH
  install_bower_deps
  cd - > /dev/null
}

install_bower_deps() {
  local bower_dir=$build_dir/bower.json

  if [ -f $bower_dir ]; then
    info "Installing and caching bower components"
    cp -f $bower_dir ./
    bower install
    cp -r bower_components $build_dir
  fi
}

build_static_assets() {
  info "Building Phoenix static assets"
  cd $build_dir

  brunch build --production 2>&1 | indent

  PATH=$build_dir/.platform_tools/erlang/bin:$PATH
  PATH=$build_dir/.platform_tools/elixir/bin:$PATH
  mix phoenix.digest 2>&1 | indent

  cd - > /dev/null
}

cache_versions() {
  info "Caching versions for future builds"
  echo `node --version` > $cache_dir/node-version
  echo `npm --version` > $cache_dir/npm-version
}

write_profile() {
  info "Creating runtime environment"
  mkdir -p $build_dir/.profile.d
  local export_line="export PATH=\"\$HOME/.heroku/node/bin:\$HOME/bin:\$HOME/node_modules/.bin:\$PATH\"
                     export MIX_ENV=${MIX_ENV}"
  echo $export_line >> $build_dir/.profile.d/phoenix_static_buildpack_paths.sh
}
