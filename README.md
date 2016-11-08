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

    ```elixir
    defmodule MyRouter do
      use Plug.Router

      plug Plexy.RequestId
      plug Plexy.Instrumentor
      plug :match
      plug :dispatch
    end
    ```

  3. Call the `Plexy.Logger` wherever you wish to log information:

    ```elixir
    Plexy.Logger.count(:http_clients_404, 1)
    ```

## Usage

Import the plugs into your Plug router or your Phoenix router pipeline as necessary. You can also import the plugs into your own plugs, as needed.

## Concepts

### Logs-as-data

By publishing consistent and machine-interpretable logs, we are able to monitor our applications and trace requests with tools like Librato and splunk.

It is useful to think of logs as data, instead of just as strings. For logs-as-data, we want to publish logs like

```
flag1 key1=val1 key2=val2 flag2
```

This is known as an [`l2met`](https://github.com/ryandotsmith/l2met) compatible log format. Outputting logs in this format will allow integrations like Librato to easily show graphs of this data, and allows us to search Splunk for matching loglines.

To output arbitrary data to the log, you can pass a hash to `Plexy.Logger` and it will format it correctly. For example:

```
Plexy.Logger.info(test: true, foo: "bar")
```

becomes

```
21:02:24.882 request_id=fc06cbd2-b8b6-4257-801d-89253ed83962  test=true foo=bar
```

You do not need to worry about converting this hash into a string correctly. `Plexy.Logger` has you covered!

### Request IDs

Request IDs are a unique identifier associated with every single request your Plexy app receives. Importing the `Plexy.RequestId` plug will append the request ID to the connection and also make it available in the Logger metadata.

Request IDs are read on the request coming in to the app, so if you are on a platform like Heroku that adds Request ID headers, Plexy can read the existing Request ID(s) and append its own Request ID to the list. By default, it reads out of the the list of headers `["Request-Id", "X-Request-Id"]` for incoming requests, but you can configure this list by setting `req_headers` in `Config`.

Similarly, it defaults to setting a `Request-Id` header on the response so that you can easily trace requests. To customize this header, set `res_header` in `Config`.

### Request/response instrumentation

By default, Plexy will instrument each request and output the timing information in loglines. This, in addition with a request ID, makes it possible to splunk for a particular request and see information about its performance, HTTP response code, etc. An example request / response might look like this in logs:

```
21:02:24.882 request_id=fc06cbd2-b8b6-4257-801d-89253ed83962  at=start instrumentation=true method=GET path=/hello
21:02:24.884 request_id=fc06cbd2-b8b6-4257-801d-89253ed83962  <metrics>
21:02:24.884 request_id=fc06cbd2-b8b6-4257-801d-89253ed83962  at=finish elapsed=1.387 status=200
```

### Metrics

Plexy provides some helper functions for taking metric measurements and outputting those metrics to the logs.

#### Counts

`Plexy.Logger.count(metric_name, count)` will log the given metric as a count for easy graphing in Librato.

#### Measures

`Plexy.Logger.measure(metric_name, func)` will measure the amount of time in milliseconds required to run the given function and logs it as the given metric name.


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
