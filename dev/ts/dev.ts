console.log("load local script")

document.body.addEventListener('dragover', function(event) {
  event.preventDefault()
});

document.body.addEventListener('drop', function(event) {
  event.preventDefault()

  const files = event?.dataTransfer?.files;
  if (!files) { return }
  for (let i = 0; i < files.length; i++) {
    const file = files.item(i);
    if (file) { embed(file) }
  }
});

function embed(file: File): void {
  const reader = new FileReader();
  reader.onload = function(event) {
    const result = event?.target?.result;
    sendData({
      name: file.name,
      type: file.type,
      pathname: location.pathname,
      result: result
    })
  };
  reader.readAsDataURL(file);
}

function sendData(data: object): void {
  fetch('/dev/embed', {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
    },
    body: JSON.stringify(data)
  })
}
