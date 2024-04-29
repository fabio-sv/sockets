import os, json, boto3

client = boto3.client("apigatewaymanagementapi", endpoint_url=os.getenv("API_ENDPOINT"))
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.getenv("TABLE_NAME"))


def get_body(event):
    body = {}
    try:
        if "body" in event:
            body = json.loads(event["body"])
    except Exception as e:
        print(e)
    finally:
        return body


async def get_all_connections(exclude_ids):
    connections = table.scan()
    return [
        item for item in connections["Items"] if item["connectionId"] not in exclude_ids
    ]


def handler(event, _):
    if "requestContext" not in event:
        return {
            "statusCode": 400,
            "body": json.dumps(
                {
                    "message": "Nothing to work with",
                }
            ),
        }

    body = get_body(event)

    connections = get_all_connections([event["requestContext"]["connectionId"]])
    promises = []
    for connection in connections:
        promises.append(
            client.post_to_connection(
                ConnectionId=connection["connectionId"],
                Data=json.dumps(body).encode("utf-8"),
            )
        )

    for promise in promises:
        promise.wait()

    return {"statusCode": 200, "body": json.dumps({"message": "Messages sent"})}
