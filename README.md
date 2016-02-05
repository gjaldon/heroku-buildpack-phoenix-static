# Phoenix Static Buildpack

## Purpose

This buildpack is meant to be used with the [Heroku Buildpack for Elixir](https://github.com/HashNuke/heroku-buildpack-elixir). When deploying Phoenix apps to Heroku, static assets will need to be compiled. This buildpack sees to it that static assets are compiled and that a corresponding asset manifest is generated.

## Features
* Easily customizable to your build needs with its `compile` hook!
* Works much like the [Heroku Buildpack for Elixir](https://github.com/HashNuke/heroku-buildpack-elixir)!
* **Easy configuration** with `phoenix_static_buildpack.config` file
* Automatically sets `DATABASE_URL`
* If your app doesn't have a Procfile, default web task `mix phoenix.server` will be run
* Can configure versions for Node and NPM
* Auto-installs Bower deps if `bower.json` is in your app's root path
* Caches Node, NPM modules and Bower components

## Usage

```bash
# Set the buildpack for your Heroku app
heroku buildpacks:set https://github.com/gjaldon/phoenix-static-buildpack

# Add this buildpack after the Elixir buildpack
heroku buildpacks:add --index 1 https://github.com/HashNuke/heroku-buildpack-elixir
```

## Configuration

Create a `phoenix_static_buildpack.config` file in your app's root dir if you want to override the defaults. The file's syntax is bash.

If you don't specify a config option, then the default option from the buildpack's [`phoenix_static_buildpack.config`](https://github.com/gjaldon/phoenix-static-buildpack/blob/master/phoenix_static_buildpack.config) file will be used.


__Here's a full config file with all available options:__

```bash
# We can set the version of Node to use for the app here
node_version=0.12.4

# We can set the version of NPM to use for the app here
npm_version=2.10.1

# Add the config vars you want to be exported here
config_vars_to_export=(DATABASE_URL)

# We can change the filename for the compile script with this option
compile="compile"
```

## Compile

By default, Phoenix uses `brunch` and recommends you to use `mix phoenix.digest` in production. For that, we have a default `compile` shell script which gets run after building dependencies and
just before finalizing the build. The `compile` file looks like this:

```bash
info "Building Phoenix static assets"
brunch build --production
mix phoenix.digest
```

To customize your app's compile hook, just add a `compile` file to your app's root directory.
`compile` is just a shell script, so you can use any valid `bash` code. Keep in mind you'll have
access to your `node_modules` and `mix`. This means that if you're using a Node build tool other than `brunch`, you can just do something like:

```bash
# app_root/compile
gulp build:dist
mix phoenix.digest
```

The above `compile` overrides the default one. :)
