import { writable } from 'svelte/store';
import type { Message } from '../types';
import { parse } from '../utils/parse';

const messages = writable<Message[]>([]);

const socket = new WebSocket(import.meta.env.VITE_APP_WS_URL);

socket.addEventListener('open', (event: Event) => {
  console.info('Socket connected');
});

socket.addEventListener('close', (event: Event) => {
  console.info('Socket disconnected');
});

socket.addEventListener('message', (event: MessageEvent) => {
  const json = parse(event.data);

  const newMessage: Message = {
    message: json.message,
    self: false,
    from: 'other',
    time: new Date(),
  };

  messages.update((prev) => [...prev, newMessage]);
});

const sendMesssage = (message: string) => {
  const newMessage: Message = {
    message: message,
    self: true,
    from: 'user',
    time: new Date(),
  };

  messages.update((prev) => [...prev, newMessage]);

  if (socket.readyState > 1) {
    return;
  }

  socket.send(
    JSON.stringify({
      action: 'sendmessage',
      message: message,
    })
  );
};

export { messages, sendMesssage };
