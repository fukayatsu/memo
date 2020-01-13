export default class Reloader {
  listen() {
    const ws = new WebSocket('ws://localhost:9293');
    ws.addEventListener('open', (event) => {
      console.log('ws:open', event)
    });

    ws.addEventListener('close', (event) => {
      console.log('ws:close', event);
      console.log('Reloading...')
      setTimeout(() => { location.reload() }, 1000)
    });
  }
}
