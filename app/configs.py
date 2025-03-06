from pydantic_settings import BaseSettings, SettingsConfigDict

model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="allow")


class AppSettings(BaseSettings):
    model_config = model_config
    APP_ENV: str = "development"


app_settings = AppSettings()
