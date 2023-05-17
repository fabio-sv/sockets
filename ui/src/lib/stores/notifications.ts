import { writable } from 'svelte/store';
import type { INotification, Type } from '../types';

const notifications = writable<INotification[]>([]);

const push = (message: string, type: Type) => {
  const notification: INotification = {
    message,
    type,
    time: new Date(),
  };

  notifications.update((prev) => [...prev, notification]);
};

export { notifications, push };
