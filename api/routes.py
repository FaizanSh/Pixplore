from fastapi import APIRouter, HTTPException
from helpers import search_label

router = APIRouter()

@router.get("/search", response_model=dict, summary="Search by label", description="Search for a label with optional filters for country and language.")
def search(event: SearchEvent):
    """
    Search for a label using the given parameters.

    Args:
        event (SearchEvent): Input payload containing label, country, and language.

    Returns:
        dict: Response from the `search_label` helper function.
    """
    try:
        # Pass all parameters only if they are provided
        if event.country and event.language:
            response = search_label(event.label, event.country, event.language)
        else:
            response = search_label(event.label)

        # Handle empty responses or errors
        if not response:
            raise HTTPException(status_code=404, detail="No results found.")

        return response

    except KeyError as e:
        raise HTTPException(status_code=400, detail=f"Missing required field: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")