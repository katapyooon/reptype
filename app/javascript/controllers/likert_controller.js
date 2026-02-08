import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.answers = {}
    this.updateSubmitButton()
  }

  select(event) {
    const value = Number(event.target.dataset.value)
    let questionEl = event.target.closest(".question-item") || event.target.closest(".question")

    // fallback: find by data-question-id attribute on the clicked element
    if (!questionEl) {
      const qid = event.target.dataset.questionId
      if (qid) {
        questionEl = document.querySelector(`[data-question-id="${qid}"]`)
      }
    }

    // 同じ質問の dot を取得
    const dots = questionEl ? questionEl.querySelectorAll(".dot") : [event.target]

    dots.forEach((dot, index) => {
      dot.classList.toggle("selected", index < value)
    })

    const questionId = questionEl ? questionEl.dataset.questionId : event.target.dataset.questionId
    this.answers[questionId] = value

    // 送信ボタンの状態を更新
    this.updateSubmitButton()

    // 回答をデータベースに保存
    fetch("/answers", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content")
      },
      body: JSON.stringify({
        answer: {
          question_id: questionId,
          score: value
        }
      })
    })
  }

  updateSubmitButton() {
    // 全問に回答したかチェック
    const questionCount = document.querySelectorAll(".question-item").length
    const answeredCount = Object.keys(this.answers).length

    const submitButton = document.getElementById("submit-button")
    const answersContainer = document.getElementById("answers-container")

    // 全問回答完了時、フォームに回答データを追加
    if (answeredCount === questionCount && questionCount > 0) {
      submitButton.disabled = false
      // フォームに回答データを追加
      answersContainer.innerHTML = ""
      Object.entries(this.answers).forEach(([questionId, score]) => {
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = `answers[${questionId}]`
        input.value = score
        answersContainer.appendChild(input)
      })
    } else {
      submitButton.disabled = true
    }
  }
}
