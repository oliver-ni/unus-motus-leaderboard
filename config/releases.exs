import Config

config :unus_motus,
  db_uri: System.fetch_env!("DB_URI")
