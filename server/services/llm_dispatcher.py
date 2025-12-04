from services.gemini_service import GeminiService
from services.nofiltergpt_service import NoFilterGPTService


class LLMDispatcher:
    def __init__(self):
        self.gemini = GeminiService()
        self.nofilter = NoFilterGPTService()

    def generate(self, llm: str, prompt: str):
        if llm == "NoFilterGPT":
            yield from self.nofilter.generate(prompt)
        else:
            yield from self.gemini.generate(prompt)
