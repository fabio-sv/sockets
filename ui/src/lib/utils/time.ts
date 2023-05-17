export const formatTime = (time: Date) => {
  return time.toLocaleTimeString(['en-US'], {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });
};
