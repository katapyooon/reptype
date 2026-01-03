import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["question", "result"]
  static values = { questions: Array }

  connect() {
    console.log("Likert controller connected")  // デバッグ追加
    console.log("Questions:", this.questionsValue)  // データ確認
    this.currentIndex = 0
    if (this.questionsValue.length > 0) {
      this.showQuestion()
      return
    }else {
        this.questionTarget.innerHTML = "<p>質問がありません</p>"
    }   
  }

  select(event) {
    const value = event.target.dataset.value
    console.log(`Question ${this.currentIndex + 1}: ${value}`)  // 回答をログ（必要に応じて保存処理追加）

    fetch("/answers", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({
        answer: {
          question_id: this.questionsValue[this.currentIndex].id,
          score: value
        }
      })
    })

    this.currentIndex++
    if (this.currentIndex < this.questionsValue.length) {
      this.showQuestion()
    } else {
      this.showResult()
    }
  }

  showQuestion() {
    const question = this.questionsValue[this.currentIndex]
    this.questionTarget.innerHTML = `
      <p>${question.content}</p>
      <div>
        <button data-action="click->likert#select" data-value="1">1 (Strongly Disagree)</button>
        <button data-action="click->likert#select" data-value="2">2 (Disagree)</button>
        <button data-action="click->likert#select" data-value="3">3 (Neutral)</button>
        <button data-action="click->likert#select" data-value="4">4 (Agree)</button>
        <button data-action="click->likert#select" data-value="5">5 (Strongly Agree)</button>
      </div>
    `
  }

  showResult() {
    this.questionTarget.style.display = "none"
    this.resultTarget.style.display = "block"
  }
}