const AWS = require('aws-sdk');

const table = 'your-table-name';
const CONNECTION_URL = 'your-endpoint';
const client = new AWS.ApiGatewayManagementApi({ endpoint: CONNECTION_URL });
const dynamo = new AWS.DynamoDB.DocumentClient();

const getBody = (event) => {
  let body = {};
  try {
    if (event.body) {
      body = JSON.parse(event.body);
    }
  } catch (err) {
    console.error(err);
  } finally {
    return body;
  }
};

const getAllConnections = async (excludeIds) => {
  const connections = await dynamo
    .scan({
      TableName: table,
    })
    .promise();

  return connections.Items.filter(
    (item) => !excludeIds.includes(item.connectionId)
  );
};

const handler = async (event) => {
  if (!event.requestContext) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Nothing to work with',
      }),
    };
  }

  let body = getBody(event);

  event.requestContext.connectionId;

  const connections = await getAllConnections([
    event.requestContext.connectionId,
  ]);
  const promises = connections.map((connection) =>
    client
      .postToConnection({
        ConnectionId: connection.connectionId,
        Data: Buffer.from(JSON.stringify(body)),
      })
      .promise()
  );
  await Promise.all(promises);

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Messages sent' }),
  };
};

module.exports = { handler };
