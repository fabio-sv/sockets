# Sockets - The full stack

There are 3 parts to this app. The infrastructure, the backend, and the frontend.

1. The infrastructure

The infrastructure can be found in `infrastructure/` which houses terraform to create AWS resources required to deploy this app.
It is worth noting that this app is serverless.

2. The Backend

The backend can be found in `functions/` which are python functions that are designed to be deployed on Lambda.

3. The Frontend

The frontend can be found in `ui/` which is a Svelte web app used to connect to the API.

## The point

### What is the point of this app?

To demonstrate how you would use Websockets in a serverless architecture since websocket apps usually require servers to maintain the connection.

#### How does this app manage those connections?

Since Lambda's are short lived bundles of joy, the lambda's don't maintain the connection, API Gateway does.

The WebSocket API Gateway has 3 routes to begin with:

1. `$connect`
2. `$disconnect`
3. `$default`

You can create more, and in this app, I created a route called `send`.

###### `$connect`

When the client connects, API Gateway picks it up, and calls the integration proxy attached to the `$connect` event, in this case, a Lambda.
In this lambda, the `connectionId` should be recorded. I used DynamoDB to do so. This is how we will then send a message back to this same client later on.

- JavaScript example:

```javascript
const connectionUrl = 'wss://your-domain.com/stage';
const socket = new WebSocket(connectionUrl);

socket.addEventListener('open', (event) => {
  console.info('Socket connected');
});
```

###### `$disconnect`

When the client disconnects, API Gateway will again pick it up, and call the associated integration proxy attached to `$disconnect`, again, a Lambda.
In this lambda, you will get the `connectionId` in the event's request context, and can then remove this id from your table. This is how we cleanup the user
that was saved in `$connect`.

- JavaScript example

```javascript
socket.close(); // To trigger the close manually

// OR

// To listen to the close event
socket.addEventListener('close', (event) => {
  console.info('Socket disconnected');
});
```

###### `send`

When the client emits the action `'send'`, API Gateway picks it up, and calls the associated Lambda once again. The lambda then fetches all the connection ids in
the DynamoDB table barring it's own, and sends a message to each one. If private messaging is required, then this would have to be implemented in similar patterns to servered architectures.

```javascript
// To send a message
socket.send(
  JSON.stringify({
    action: 'send', // exact match to route
    message: message, // anything you want
  })
);

// OR

// To listen for a message
socket.addEventListener('message', (event) => {
  const json = JSON.parse(event.data);

  messages.push(json.message);
});
```

## Pipeline

In terms of the pipeline, there is no pipeline.
But to get started, run:
```sh
# Authenticate with AWS
# install pnpm
make install
make deploy
```
