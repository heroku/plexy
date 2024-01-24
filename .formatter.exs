# Used by "mix format"
[
  locals_without_parens: [on_exit: 1],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:plug]
]
