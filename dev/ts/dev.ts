import DragAndDrop from "./dragAndDrop.js";
import Reloader from "./reloader.js"

window.addEventListener('DOMContentLoaded', () => {
  (new DragAndDrop).listen();
  (new Reloader).listen();
  console.log("Local scripts loaded.")
});
