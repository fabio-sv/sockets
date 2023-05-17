export type Type = 'good' | 'bad';

export interface INotification {
  message: string;
  type: Type;
  time: Date;
}
