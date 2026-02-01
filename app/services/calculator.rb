class Calculator
    # Initialize with a collection of Answer records (or array-like objects)
    def initialize(answers = [])
        @answers = answers.to_a
    end

    # Compute the final result code by category order A, B, C, D.
    # For each category we sum the scores of answers whose question.category matches,
    # then return "L" if the sum < 13, otherwise "H".
    def result_code
        %w[A B C D].map { |cat| category_letter(cat) }.join
    end

    private

    def category_letter(category)
        # Safely handle answers that might not have associated questions loaded
        score = @answers.sum do |answer|
            q = answer.respond_to?(:question) ? answer.question : nil
            q && q.category == category ? (answer.respond_to?(:score) ? answer.score.to_i : answer.value.to_i) : 0
        end

        score < 13 ? "L" : "H"
    end
end
