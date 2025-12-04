from fastapi import APIRouter, WebSocket
import asyncio

from services.search_service import SearchService
from services.sort_source_service import SortSourceService
from services.llm_dispatcher import LLMDispatcher

router = APIRouter()

search_service = SearchService()
sort_service = SortSourceService()
llm_dispatcher = LLMDispatcher()


@router.websocket("/ws/chat")
async def websocket_chat(websocket: WebSocket):
    await websocket.accept()

    try:
        data = await websocket.receive_json()

        query = data.get("query")
        llm = data.get("llm", "Gemini 2.5")
        instruction = data.get("instruction", "")
        behavior = data.get("behavior", "Default")
        history = data.get("history", [])
        search_mode = data.get("search_mode", True)  # 🔥 NEW

        print("\n========== WS RECEIVED ==========")
        print("Query:", query)
        print("LLM:", llm)
        print("Instruction:", instruction)
        print("Behavior:", behavior)
        print("Search Mode:", search_mode)
        print("History items:", len(history))
        print("=================================\n")

        # ------- Personality -------
        personality = f"""
Personality Settings:
Custom Instruction: {instruction}
Behavior Mode: {behavior}

Follow these personality rules strictly unless the user explicitly overrides them.
"""

        # ------- Conversation history -------
        history_text = ""
        for msg in history:
            role = msg.get("role")
            content = msg.get("content")
            if not role or not content:
                continue
            history_text += f"{role.capitalize()}: {content}\n"

        # ------- RAG / Search (depending on search_mode) -------
        if search_mode:
            search_results = search_service.web_search(query)
            sorted_results = sort_service.sort_sources(query, search_results)

            # Kirim sources ke client
            await websocket.send_json({
                "type": "search_results",
                "data": sorted_results
            })

            context = "\n\n".join(
                f"Source {i+1} ({res['url']}):\n{res['content']}"
                for i, res in enumerate(sorted_results)
            )
        else:
            # TANPA web search
            sorted_results = []
            context = ""

        # ------- Final prompt -------
        prompt = f"""
{personality}

Conversation History:
{history_text}

Context:
{context}

User: {query}
Assistant:
"""

        # ------- Stream response -------
        for chunk in llm_dispatcher.generate(llm, prompt):
            await websocket.send_json({
                "type": "content",
                "data": chunk
            })
            await asyncio.sleep(0.03)

    except Exception as e:
        print("❌ WS Error:", e)

    finally:
        await websocket.close()
