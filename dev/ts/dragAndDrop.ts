export default class DragAndDrop {
  listen() {
    document.body.addEventListener('dragover', (event) => {
      event.preventDefault()
    });

    document.body.addEventListener('drop', (event) => {
      event.preventDefault()

      const files = event?.dataTransfer?.files;
      if (!files) { return }
      for (let i = 0; i < files.length; i++) {
        const file = files.item(i);
        if (file) { this.embed(file) }
      }
    });
  }

  private embed(file: File): void {
    const reader = new FileReader();
    reader.onload = (event) => {
      const result = event?.target?.result;
      this.sendData({
        name: file.name,
        type: file.type,
        pathname: location.pathname,
        result: result
      })
    };
    reader.readAsDataURL(file);
  }

  private sendData(data: object): void {
    fetch('/dev/embed', {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
      },
      body: JSON.stringify(data)
    })
  }
}
