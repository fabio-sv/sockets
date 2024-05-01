import { writable } from 'svelte/store';
import type { IMessage } from '../types';
import { parse } from '../utils/parse';
import { push } from './notifications';

const messages = writable<IMessage[]>([]);

const socket = new WebSocket(import.meta.env.VITE_API_URL);

socket.addEventListener('open', (event: Event) => {
  push('Connected succesfully!', 'good');
});

socket.addEventListener('close', (event: Event) => {
  push('Disconnected from server', 'bad');
});

socket.addEventListener('message', (event: MessageEvent) => {
  const json = parse(event.data);

  const newMessage: IMessage = {
    message: json.message,
    self: false,
    from: 'other',
    time: new Date(),
  };

  messages.update((prev) => [...prev, newMessage]);
});

const sendMesssage = (message: string) => {
  const newMessage: IMessage = {
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
      action: 'send',
      message: message,
    })
  );
};

export { messages, sendMesssage };
