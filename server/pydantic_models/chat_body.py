from pydantic import BaseModel


class ChatBody(BaseModel):
    query: str
    llm: str = "Gemini 2.5"  # default, sama kayak dropdown
