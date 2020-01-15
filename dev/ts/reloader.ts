export default class Reloader {
  listen() {
    const ws = new WebSocket(`ws://${process.env.RELOADER_HOST}`);
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
