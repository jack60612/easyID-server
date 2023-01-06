from typing import Union

from fastapi import FastAPI
import uvicorn

ROOT_PATH = "/pyapi/v1/"

app = FastAPI(root_path=ROOT_PATH)


@app.get("/")
def read_root():
    return {"version": "1", "message": "Hello World", "status": "OK"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
