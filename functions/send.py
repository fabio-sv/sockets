import os, json, boto3

api = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=os.getenv("API_ENDPOINT").replace("wss:", "https:"),
)
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.getenv("TABLE_NAME"))


def get_all_connections(exclude_ids):
    response = table.scan(ProjectionExpression="connectionId")

    return [
        item["connectionId"]
        for item in response["Items"]
        if item["connectionId"] not in exclude_ids
    ]


def handler(event, _):
    body = json.loads(event["body"])
    connections = get_all_connections([event["requestContext"]["connectionId"]])

    for connection in connections:
        api.post_to_connection(
            ConnectionId=connection,
            Data=json.dumps(body).encode("utf-8"),
        )

    return {"statusCode": 200, "body": json.dumps({"message": "Messages sent"})}
