export interface Payload {
  action: string;
  message: string;
  [key: string]: unknown;
}

export interface IMessage {
  message: string;
  self: boolean;
  from: string;
  time: Date;
}
