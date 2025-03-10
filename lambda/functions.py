import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])

def lambda_handler(event, context):
    try:
        response = table.scan()  # Retrieves all items from the table

        items = response.get("Items", [])

        return {
            "statusCode": 200,
            "body": json.dumps(items),
            "headers": {"Content-Type": "application/json"},
        }
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
