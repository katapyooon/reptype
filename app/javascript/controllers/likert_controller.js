import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  select(event) {
    const value = Number(event.target.dataset.value)
    const questionEl = event.target.closest(".question")

    // 同じ質問の dot を取得
    const dots = questionEl.querySelectorAll(".dot")

    dots.forEach((dot, index) => {
      dot.classList.toggle("selected", index < value)
    })

    const questionId = questionEl.dataset.questionId

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
}
