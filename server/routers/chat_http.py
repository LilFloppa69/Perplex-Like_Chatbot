from fastapi import APIRouter
from pydantic_models.chat_body import ChatBody
from services.search_service import SearchService
from services.sort_source_service import SortSourceService
from services.llm_dispatcher import LLMDispatcher

router = APIRouter()

search_service = SearchService()
sort_service = SortSourceService()
llm_dispatcher = LLMDispatcher()


@router.post("/chat")
def chat_http(body: ChatBody):
    query = body.query
    llm = body.llm

    print(f"[HTTP] Query: {query}, LLM: {llm}")

    # SEARCH
    results = search_service.web_search(query)
    sorted_results = sort_service.sort_sources(query, results)

    # BUILD PROMPT
    context = "\n\n".join(
        f"Source {i+1} ({r['url']}):\n{r['content']}"
        for i, r in enumerate(sorted_results)
    )

    prompt = (
        "You are an advanced model with strong reasoning.\n\n"
        f"Context:\n{context}\n\n"
        f"Query: {query}\n\n"
        "Provide a detailed and accurate answer."
    )

    # GENERATE (entire text, NOT streamed)
    full_text = "".join(llm_dispatcher.generate(llm, prompt))

    return {
        "query": query,
        "llm": llm,
        "answer": full_text,
        "sources": sorted_results
    }
