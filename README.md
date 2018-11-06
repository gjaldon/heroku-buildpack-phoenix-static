# Phoenix Static Buildpack

## Purpose

This buildpack is meant to be used with the [Heroku Buildpack for Elixir](https://github.com/HashNuke/heroku-buildpack-elixir). When deploying Phoenix apps to Heroku, static assets will need to be compiled. This buildpack sees to it that static assets are compiled and that a corresponding asset manifest is generated.

## Features
* Easily customizable to your build needs with its `compile` hook!
* Works much like the [Heroku Buildpack for Elixir](https://github.com/HashNuke/heroku-buildpack-elixir)!
* **Easy configuration** with `phoenix_static_buildpack.config` file
* Automatically sets `DATABASE_URL`
* If your app doesn't have a Procfile, default web task `mix phx.server` will be run
* Can configure versions for Node and NPM
* Auto-installs Bower deps if `bower.json` is in your app's root path
* Caches Node, NPM modules and Bower components

## Usage

```bash
# Create a Heroku instance for your project
heroku apps:create my_heroku_app

# Set and add the buildpacks for your Heroku app
heroku buildpacks:set https://github.com/HashNuke/heroku-buildpack-elixir
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static

# Deploy
git push heroku master
```

### Serve with Sass assets

If your project serves Sass assets, you need the sass binary for `sass-brunch` via ruby buildpack.

Create a `Gemfile` to include the `sass` gem:
```
source 'https://rubygems.org'
ruby '2.3.1'
gem 'sass'
```

Then run generate the `Gemfile.lock`:
```bash
bundle install
```

Finally, add the ruby buildpack.
```bash
# Add the ruby buildpack to your Heroku app
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-ruby
```

## Configuration

Create a `phoenix_static_buildpack.config` file in your app's root dir if you want to override the defaults. The file's syntax is bash.

If you don't specify a config option, then the default option from the buildpack's [`phoenix_static_buildpack.config`](https://github.com/gjaldon/heroku-buildpack-phoenix-static/blob/master/phoenix_static_buildpack.config) file will be used.


__Here's a full config file with all available options:__

```bash
# Clean out cache contents from previous deploys
clean_cache=false

# We can change the filename for the compile script with this option
compile="compile"

# We can set the version of Node to use for the app here
node_version=5.3.0

# We can set the version of NPM to use for the app here
npm_version=2.10.1

# We can set the path to phoenix app. E.g. apps/phoenix_app when in umbrella.
phoenix_relative_path=.

# Remove node and node_modules directory to keep slug size down if it is not needed.
remove_node=false

# We can change path that npm dependencies are in relation to phoenix app. E.g. assets for phoenix 1.3 support.
assets_path=.

# We can change phoenix mix namespace tasks. E.g. phx for phoenix 1.3 support.
phoenix_ex=phoenix
```

## Compile

By default, Phoenix uses `brunch` and recommends you to use `mix phoenix.digest` in production. For that, we have a default `compile` shell script which gets run after building dependencies and
just before finalizing the build. The `compile` file [looks like this](https://github.com/gjaldon/heroku-buildpack-phoenix-static/blob/master/compile).

To customize your app's compile hook, just add a `compile` file to your app's root directory.
`compile` is just a shell script, so you can use any valid `bash` code. Keep in mind you'll have
access to your `node_modules` and `mix`. This means that if you're using a Node build tool other than `brunch`, you can just do something like:

```bash
# app_root/compile
cd $phoenix_dir
npm --prefix ./assets run build
mix "${phoenix_ex}.digest" #use the ${phoenix_ex} variable instead of hardcoding phx or phoenix
```

The above `compile` overrides the default one. :)


## FAQ

1. When to use?
- This buildpack is only necessary when you need to compile static assets during deploys. You will not need this buildpack if you are using Phoenix only as a REST API.

2. Do I need `heroku-buildpack-nodejs` with this?
- No, this buildpack installs Node for you. How it differs from the NodeJS buildpack
is that it adds `mix` to the PATH so you can run `mix` commands like `mix phoenix.digest`.
