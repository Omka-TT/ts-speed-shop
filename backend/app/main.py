from fastapi import FastAPI
from .database import engine, Base
from .api.endpoints import auth, products

Base.metadata.create_all(bind=engine)

app = FastAPI(title="TS-SPEED-SHOP API")
app.include_router(auth.router)
app.include_router(products.router)



