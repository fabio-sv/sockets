import os, json, boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.getenv("TABLE_NAME"))


def handler(event, _):
    connection_id = event["requestContext"]["connectionId"]
    table.put_item(Item={"connectionId": connection_id})

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Connected successfully."}),
    }
