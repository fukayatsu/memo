"use strict";
console.log("load local script");
document.body.addEventListener('dragover', function (event) {
    event.preventDefault();
});
document.body.addEventListener('drop', function (event) {
    var _a, _b;
    event.preventDefault();
    var files = (_b = (_a = event) === null || _a === void 0 ? void 0 : _a.dataTransfer) === null || _b === void 0 ? void 0 : _b.files;
    if (!files) {
        return;
    }
    for (var i = 0; i < files.length; i++) {
        var file = files.item(i);
        if (file) {
            embed(file);
        }
    }
});
function embed(file) {
    var reader = new FileReader();
    reader.onload = function (event) {
        var _a, _b;
        var result = (_b = (_a = event) === null || _a === void 0 ? void 0 : _a.target) === null || _b === void 0 ? void 0 : _b.result;
        sendData({
            name: file.name,
            type: file.type,
            pathname: location.pathname,
            result: result
        });
    };
    reader.readAsDataURL(file);
}
function sendData(data) {
    fetch('/dev/embed', {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=utf-8",
        },
        body: JSON.stringify(data)
    });
}
