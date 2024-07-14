from fastapi import FastAPI, Header, HTTPException
import httpx
import asyncio
import json

app = FastAPI()


URL = "https://api.quotable.io/random"


async def request(client):
    response = await client.get(URL)
    response_load = json.loads(response.text)

    return response.status_code, response_load

@app.get("/")
async def root():
    return {"Message": "API Running Success"}


@app.get("/healthcheck")
async def healthcheck():
    return {"health": "true", 'status_code': '200'}


@app.get("/v1/fortune")
async def fortune():
    async with httpx.AsyncClient() as client:
        result = await asyncio.gather(request(client))

        if result[0][0] != 200:
            raise HTTPException(status_code=404, detail="Unable to get the quote")
        
        message = result[0][1]["content"]
        author = result[0][1]["author"]

    return {"message": message, "author": author}
