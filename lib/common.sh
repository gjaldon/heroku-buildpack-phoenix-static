indent() {
  sed -u 's/^/       /'
}

head() {
  echo ""
  echo "-----> $*"
}

load_config() {
  head "Checking Node version to use"

  local custom_config_file="${build_path}/phoenix_static_buildpack.config"

  # Source for default versions file from buildpack first
  source "${build_pack_path}/phoenix_static_buildpack.config"

  if [ -f $custom_config_file ]; then
    source $custom_config_file
  else
    indent "WARNING: phoenix_static_buildpack.config wasn't found in the app"
    indent "Using default config from Phoenix static buildpack"
  fi

  indent "Will use the following versions:"
  indent "* Node ${node_version}"
  indent "Will export the following config vars:"
  indent "* Config vars ${config_vars_to_export[*]}"
}

export_config_vars() {
  for config_var in ${config_vars_to_export[@]}; do
    if [ -d $env_path ] && [ -f $env_path/${config_var} ]; then
      export ${config_var}=$(cat $env_path/${config_var})
    fi
  done
}

export_mix_env() {
  if [ -d $env_path ] && [ -f $env_path/MIX_ENV ]; then
    export MIX_ENV=$(cat $env_path/MIX_ENV)
  else
    export MIX_ENV=prod
  fi

  indent "* MIX_ENV=${MIX_ENV}"
}
