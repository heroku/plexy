use Mix.Config

config :plexy, :logger,
  redactors: [
    {Plexy.Logger.SimpleRedactor, [redact: ["password"], filter: ["secret"]]}
  ]
