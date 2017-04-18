use Mix.Config

config :cheese_me,
  http: [port: 8080],
  url: [host: "cheezy.neil-concepts.com"],
  cache_static_manifest: "priv/static/manifest.json",
  server: true
