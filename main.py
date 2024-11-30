from fastapi import FastAPI
from api.routes import router

app = FastAPI()

# Include API routes
app.include_router(router)

# Basic Hello World route
@app.get("/")
def read_root():
    return {"message": "Hello, World!"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)