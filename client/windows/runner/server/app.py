from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import time
import json
from fastapi.responses import JSONResponse
from fastapi import FastAPI,Request
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
origins = [
   "*",  # Add your frontend URL here
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  # You can use ["*"] for testing, but it's not secure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# ComfyUI endpoint
COMFYUI_URL = "https://6cf2-124-40-247-18.ngrok-free.app"



@app.post('/prompt')
async def handle_prompt(request: Request):
    try:
        workflow_data = await request.json()
        print("Received workflow data:", workflow_data)

        if not workflow_data:
            return JSONResponse({"error": "No workflow data provided"}, status_code=400)

        comfy_response = requests.post(
            f"{COMFYUI_URL}/prompt",
            json={"prompt": workflow_data}
        )

        if comfy_response.ok:
            prompt_id = comfy_response.json().get("prompt_id")
            return JSONResponse({
                "status": "success",
                "prompt_id": prompt_id,
                "message": "Workflow queued successfully"
            })
        else:
            return JSONResponse({
                "status": "error",
                "message": f"ComfyUI error: {comfy_response.text}"
            }, status_code=500)

    except Exception as e:
        return JSONResponse({
            "status": "error",
            "message": str(e)
        }, status_code=500)

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080, debug=True)
