// ==========================================
// 個人情報検知バリデーション
// ==========================================

// パターンマッチング（正規表現）
var PII_REGEX_PATTERNS = [
  // 電話番号（固定電話・携帯）
  { pattern: /(\+81[-\s]?|0)\d{1,4}[-\s]?\d{2,4}[-\s]?\d{4}/, label: "電話番号" },
  // メールアドレス
  { pattern: /[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}/, label: "メールアドレス" },
  // クレジットカード番号（4桁×4）
  { pattern: /\b\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}\b/, label: "クレジットカード番号" },
  // 郵便番号
  { pattern: /〒?\d{3}[-\s]?\d{4}/, label: "郵便番号" },
];

// NER: 人名・組織名・地名パターン
var NER_PATTERNS = [
  // 人名: 名前 + 敬称（さん・くん・ちゃん・様・先生・氏・殿）
  { pattern: /\S{1,10}(?:さん|くん|ちゃん|様|先生|氏|殿)(?:[^\S]|$)/, label: "人名" },
  // 組織名: 法人格を含む名称
  { pattern: /(?:株式会社|有限会社|合同会社|一般社団法人|公益財団法人|学校法人|医療法人|社会福祉法人|NPO法人|一般財団法人)\S+|\S+(?:株式会社|有限会社|合同会社)/, label: "組織名" },
  // 地名: 市区町村（具体的な地名パターン）
  { pattern: /\S{2,6}[市区町村]\S{0,5}[0-9０-９丁目番地号]/, label: "地名（住所）" },
];

function detectPii(text) {
  for (var i = 0; i < PII_REGEX_PATTERNS.length; i++) {
    if (PII_REGEX_PATTERNS[i].pattern.test(text)) return true;
  }
  for (var j = 0; j < NER_PATTERNS.length; j++) {
    if (NER_PATTERNS[j].pattern.test(text)) return true;
  }
  return false;
}

// ==========================================

document.addEventListener("turbo:load", initChat);
document.addEventListener("DOMContentLoaded", initChat);

function initChat() {
  var form = document.getElementById("chat-form");
  if (!form || form.dataset.chatInitialized) return;
  form.dataset.chatInitialized = "true";

  var CHAT_URL   = form.dataset.chatUrl;
  var CSRF_TOKEN = (document.querySelector('meta[name="csrf-token"]') || {}).content || "";

  var CHAR_LIMIT = 400;

  var input    = document.getElementById("chat-question-input");
  var submit   = document.getElementById("chat-submit");
  var messages = document.getElementById("chat-messages");
  var template = document.getElementById("chat-avatar-template");
  var piiWarning = document.getElementById("chat-pii-warning");
  var charCount = document.getElementById("chat-char-count");

  function showPiiWarning() {
    if (piiWarning) piiWarning.classList.add("is-visible");
    input.classList.add("has-pii-error");
  }

  function hidePiiWarning() {
    if (piiWarning) piiWarning.classList.remove("is-visible");
    input.classList.remove("has-pii-error");
  }

  function updateCharCount() {
    var len = input.value.length;
    if (charCount) {
      charCount.textContent = len + " / " + CHAR_LIMIT;
      charCount.classList.toggle("is-over-limit", len >= CHAR_LIMIT);
    }
  }

  input.addEventListener("input", function() {
    updateCharCount();
    if (detectPii(input.value)) {
      showPiiWarning();
    } else {
      hidePiiWarning();
    }
  });

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

    if (detectPii(question)) {
      showPiiWarning();
      return;
    }
    hidePiiWarning();

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
