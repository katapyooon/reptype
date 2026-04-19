document.addEventListener("turbo:load", initChat);
document.addEventListener("DOMContentLoaded", initChat);

function initChat() {
  var form = document.getElementById("chat-form");
  if (!form || form.dataset.chatInitialized) return;
  form.dataset.chatInitialized = "true";

  var CHAT_URL   = form.dataset.chatUrl;
  var CSRF_TOKEN = (document.querySelector('meta[name="csrf-token"]') || {}).content || "";

  var input    = document.getElementById("chat-question-input");
  var submit   = document.getElementById("chat-submit");
  var messages = document.getElementById("chat-messages");
  var template = document.getElementById("chat-avatar-template");

  function makeAvatarImg() {
    if (!template) return null;
    var img = template.cloneNode();
    img.removeAttribute("id");
    img.style.display = "";
    return img;
  }

  function appendRow(side, text) {
    var row = document.createElement("div");
    row.className = "chat-row chat-row--" + side;

    if (side === "left") {
      var avatar = makeAvatarImg();
      if (avatar) row.appendChild(avatar);
    }

    var bubble = document.createElement("div");
    bubble.className = "speech-bubble speech-bubble--" + side;
    var p = document.createElement("p");
    p.textContent = text;
    bubble.appendChild(p);
    row.appendChild(bubble);

    messages.appendChild(row);
    messages.scrollTop = messages.scrollHeight;
    return row;
  }

  form.addEventListener("submit", async function(e) {
    e.preventDefault();

    var question = input.value.trim();
    if (!question) return;

    appendRow("right", question);

    var loadingBubble = document.createElement("div");
    loadingBubble.className = "speech-bubble speech-bubble--left chat-loading";
    var loadingP = document.createElement("p");
    loadingP.textContent = "回答を考え中・・・";
    loadingBubble.appendChild(loadingP);

    var loadingRow = document.createElement("div");
    loadingRow.className = "chat-row chat-row--left";
    var avatar = makeAvatarImg();
    if (avatar) loadingRow.appendChild(avatar);
    loadingRow.appendChild(loadingBubble);
    messages.appendChild(loadingRow);
    messages.scrollTop = messages.scrollHeight;

    input.value = "";
    submit.disabled = true;

    try {
      var res = await fetch(CHAT_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": CSRF_TOKEN
        },
        body: JSON.stringify({ question: question })
      });

      var data = await res.json();

      loadingRow.remove();
      appendRow("left", data.answer || "回答を取得できなかったよ。");
    } catch (_) {
      loadingRow.remove();
      appendRow("left", "エラーが発生したよ。もう一度試してみてね。");
    } finally {
      submit.disabled = false;
    }
  });
}
