# Plexy

[![Build Status](https://travis-ci.org/heroku/plexy.svg?branch=master)](https://travis-ci.org/heroku/plexy)

[Interagent](https://github.com/interagent)-compatible web services in Elixir, inspired by [Pliny](https://github.com/interagent/pliny).

Plexy helps developers write and maintain excellent APIs. It integrates well with other services by implementing logs-as-data, request/response instrumentation, request IDs, and encourages good defaults for logging and exception reporting.

Notably, Plexy is not a framework or a set of code generators. You can use Plexy's plugs with an existing Phoenix or even a vanilla Elixir web app. Plexy will work with you, not dictate how you work. It is also database agnostic.

## Installation

  1. Add `plexy` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:plexy, "~> 0.1.0"}]
    end
    ```

  2. Require Plexy plugs in your application:

    ```
    ```

## Usage

Import the plugs into your Plug router or your Phoenix router pipeline as necessary. You can also import the plugs into your own plugs.

## Concepts

### Logs-as-data

By publishing consistent and machine-interpretable logs, we are able to monitor our applications and trace requests with tools like Librato and splunk.

It is useful to think of logs as data, instead of just as strings. For logs-as-data, we want to publish logs like

```
flag1 key1=val1 key2=val2 flag2
```

This is known as an [`l2met`](https://github.com/ryandotsmith/l2met) compatible log format.

### Request IDs

### Metrics

### Request/response instrumentation

### Configuring logging

### Configuring exception reporting


## License

Created at Heroku by:

- @Adovenmuehle
- @blackfist
- @joshwlewis
- @kennyp
- @mathias

Released under the MIT license.
