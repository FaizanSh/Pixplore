from pydantic import BaseModel

# Pydantic model for input validation
class SearchEvent(BaseModel):
    label: str
    country: Optional[str] = None
    language: Optional[str] = None


