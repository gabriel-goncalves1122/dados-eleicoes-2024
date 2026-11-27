document.addEventListener("keydown", (e) => {
  if (window.parent && window.parent !== window) {
    if (["ArrowRight", "ArrowLeft", "PageDown", "PageUp", " ", "Home", "End"].includes(e.key) ||
        ["t", "f"].includes(e.key.toLowerCase())) {
      e.preventDefault();
      window.parent.postMessage({ type: "deck-key", key: e.key }, "*");
    }
  }
});
