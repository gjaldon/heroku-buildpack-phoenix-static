# Phoenix Static Buildpack

## Purpose

This buildpack is meant to be used with the [Heroku Buildpack for Elixir](https://github.com/HashNuke/heroku-buildpack-elixir). When deploying Phoenix apps to Heroku, static assets will need to be compiled. This buildpack does it for us.

## Usage

#### Create a Heroku app

```
heroku apps:create new_app_name
```

#### Set the buildpack for the Heroku app
```
heroku buildpacks:set https://github.com/HashNuke/heroku-buildpack-elixir
```

#### Add this buildpack after the Elixir buildpack
```
heroku buildpacks:add --index 1 https://github.com/gjaldon/phoenix-static-buildpack
```
