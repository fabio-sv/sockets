const AWS = require('aws-sdk');

const table = 'your-table-name';
const dynamo = new AWS.DynamoDB.DocumentClient();

const handler = async (event) => {
  if (!event.requestContext) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Nothing to work with',
      }),
    };
  }

  const connectionId = event.requestContext.connectionId;

  await dynamo
    .delete({
      TableName: table,
      Key: {
        connectionId: connectionId,
      },
    })
    .promise();

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Disconnected succesfully.' }),
  };
};

module.exports = { handler };
