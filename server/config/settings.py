from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    GEMINI_API_KEY: str
    NOFILTERGPT_API_KEY: str
    TAVILY_API_KEY: str
    STABILITY_API_KEY: str

    class Config:
        env_file = ".env"


settings = Settings()
