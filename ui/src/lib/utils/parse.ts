import type { Payload } from '../types';

export const parse = (data: string): Payload => {
  let json: Partial<Payload> = {};

  try {
    json = JSON.parse(data) as Payload;
  } catch (err) {
    console.error(err);
  } finally {
    return json as Payload;
  }
};
