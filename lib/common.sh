info() {
  #echo "`date +\"%M:%S\"`  $*"
  echo "       $*"
}

indent() {
  while read LINE; do
    echo "       $LINE" || true
  done
}

head() {
  echo ""
  echo "-----> $*"
}

file_contents() {
  if test -f $1; then
    echo "$(cat $1)"
  else
    echo ""
  fi
}

load_config() {
  info "Loading config..."

  local custom_config_file="${build_dir}/phoenix_static_buildpack.config"

  # Source for default versions file from buildpack first
  source "${build_pack_dir}/phoenix_static_buildpack.config"

  if [ -f $custom_config_file ]; then
    source $custom_config_file
  else
    info "WARNING: phoenix_static_buildpack.config wasn't found in the app"
    info "Using default config from Phoenix static buildpack"
  fi

  phoenix_dir=$build_dir/$phoenix_relative_path

  info "Will use the following versions:"
  info "* Node ${node_version}"
  info "Will export the following config vars:"
  info "* Config vars ${config_vars_to_export[*]}"
}

export_config_vars() {
  for config_var in ${config_vars_to_export[@]}; do
    if [ -d $env_dir ] && [ -f $env_dir/${config_var} ]; then
      export ${config_var}=$(cat $env_dir/${config_var})
    fi
  done
}

export_mix_env() {
  if [ -z "${MIX_ENV}" ]; then
    if [ -d $env_dir ] && [ -f $env_dir/MIX_ENV ]; then
      export MIX_ENV=$(cat $env_dir/MIX_ENV)
    else
      export MIX_ENV=prod
    fi
  fi

  info "* MIX_ENV=${MIX_ENV}"
}
