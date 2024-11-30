from fastapi import APIRouter, HTTPException
from dotenv import load_dotenv
load_dotenv()
from helpers.utils import search_label
from models.base_model import SearchEvent
import logging
import service.main_service as main
router = APIRouter()

# health check
@router.get("/", response_model=dict, summary="Health Check", description="Basic health check to ensure the service is running.")
def read_root():
    """
    Basic health check to ensure the service is running.

    Returns:
        dict: Response message.
    """
    return {"message": "Service is running."}


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
        logging.info(f"Searching for label: {event.label}")
        # Pass all parameters only if they are provided
        if event.country and event.language:
            logging.info(f"Searching for label: {event.label} in {event.country} ({event.language})")
            response = search_label(event.label, event.country, event.language)
        else:
            logging.info(f"Searching for label: {event.label}")
            response = search_label(event.label)

        # response details
        logging.info(response)

        # Handle empty responses or errors
        if not response:
            raise HTTPException(status_code=404, detail="No results found.")

        return response

    except KeyError as e:
        raise HTTPException(status_code=400, detail=f"Missing required field: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")