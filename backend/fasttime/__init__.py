from fastapi import FastAPI

app = FastAPI(title="Screentime API")


# måste ske nedanför annars blir det circular import. dvs moduler som importerar varandra. (app importeras i main)
from fasttime import main

