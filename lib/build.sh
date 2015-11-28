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

    local bower_components_dir=$cache_dir/bower_components

    if [ -d $bower_components_dir ]; then
      rm -rf $bower_components_dir
    fi
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
  if [ ! $npm_version ] || [[ `npm --version` == "$npm_version" ]]; then
    info "Using default npm version"
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

compile() {
  cd $build_dir
  PATH=$build_dir/.platform_tools/erlang/bin:$PATH
  PATH=$build_dir/.platform_tools/elixir/bin:$PATH

  run_compile

  cd - > /dev/null
}

run_compile() {
  local custom_compile="${build_dir}/${compile}"

  if [ -f $custom_compile ]; then
    info "Running custom compile"
    source $custom_compile 2>&1 | indent
  else
    info "Running default compile"
    source ${build_pack_dir}/${compile} 2>&1 | indent
  fi
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

install_sass() {
  export GEM_HOME=$build_dir/.gem/ruby/2.2.0
  export PATH=$GEM_HOME/bin:$PATH

  if test -d $cache_dir/ruby/.gem; then
    info "Restoring ruby gems directory from cache"
    cp -r $cache_dir/ruby/.gem $build_dir
    HOME=$build_dir gem update sass --user-install --no-rdoc --no-ri
    HOME=$build_dir gem install compass --user-install --no-rdoc --no-ri
  else
    HOME=$build_dir gem install sass --user-install --no-rdoc --no-ri
    HOME=$build_dir gem install compass --user-install --no-rdoc --no-ri
  fi

  rm -rf $cache_dir/ruby
  mkdir -p $cache_dir/ruby

  if test -d $build_dir/.gem; then
    info "Caching ruby gems directory for future builds"
    cp -r $build_dir/.gem $cache_dir/ruby
  fi
}