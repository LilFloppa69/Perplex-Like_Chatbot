from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers.chat_ws import router as chat_ws_router
from routers.chat_http import router as chat_http_router
from routers.image_router import router as image_router


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# setelah CORS
app.include_router(chat_ws_router)
app.include_router(chat_http_router)
app.include_router(image_router)

@app.get("/")
def root():
    return {"message": "Server is running"}
