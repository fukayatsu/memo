import DragAndDrop from "./dragAndDrop.js";

window.addEventListener('DOMContentLoaded', () => {
  (new DragAndDrop).listen();
  console.log("Local scripts loaded.")
});
