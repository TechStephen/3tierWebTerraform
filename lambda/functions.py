import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])

def get_all_items():
    response = table.scan()
    return {
        "statusCode": 200,
        "body": json.dumps(response.get("Items", [])),
        "headers": {"Content-Type": "application/json"},
    }

def get_item_by_id(item_id):
    response = table.get_item(Key={"id": item_id})
    item = response.get("Item")
    if not item:
        return {"statusCode": 404, "body": json.dumps({"error": "Item not found"})}
    return {
        "statusCode": 200,
        "body": json.dumps(item),
        "headers": {"Content-Type": "application/json"},
    }

def put_item(payload):
    required_fields = {"id", "name", "date"}
    if not required_fields.issubset(payload):
        return {"statusCode": 400, "body": json.dumps({"error": "Missing required fields"})}

    table.put_item(Item=payload)
    return {
        "statusCode": 201,
        "body": json.dumps({"message": "Item created", "item": payload}),
        "headers": {"Content-Type": "application/json"},
    }

# Lambda Entry Point (Required for AWS Lambda)
def lambda_handler(event, context):
    try:
        method = event.get("httpMethod")
        
        # GET Methods
        if method == "GET":
            params = event.get("queryStringParameters") or {}
            if "id" in params:
                return get_item_by_id(params["id"])
            else:
                return get_all_items()
        
        # POST Methods
        elif method == "POST":
            body = json.loads(event.get("body") or "{}")
            return put_item(body)
        else:
            return {
                "statusCode": 405,
                "body": json.dumps({"error": f"Method {method} not allowed"}),
            }
    
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
