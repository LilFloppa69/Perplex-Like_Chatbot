from config.settings import settings
from tavily import TavilyClient
import trafilatura


tavily_client = TavilyClient(api_key=settings.TAVILY_API_KEY)


class SearchService:
    def web_search(self, query: str):
        try:
            results = []
            
            response = tavily_client.search(
                query,
                max_results=5,
                include_answer=False,
                include_raw_content=False,
            )

            search_results = response.get("results", [])

            for result in search_results:
                content = result.get("content") or result.get("snippet")

                if not content:
                    downloaded = trafilatura.fetch_url(result.get("url"))
                    content = trafilatura.extract(downloaded) or ""

                results.append(
                    {
                        "title": result.get("title", ""),
                        "url": result.get("url", ""),
                        "content": content,
                    }
                )

            return results

        except Exception as e:
            print("SearchService Error:", e)
            return []
