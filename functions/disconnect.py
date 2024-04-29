import os, json, boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.getenv("TABLE_NAME"))


def handler(event, _):
    if "requestContext" not in event:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Nothing to work with"}),
        }

    connection_id = event["requestContext"]["connectionId"]
    table.delete_item(Key={"connectionId": connection_id})

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Disconnected successfully."}),
    }
