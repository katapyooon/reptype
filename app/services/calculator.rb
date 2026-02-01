class Calculator
  # Accepts: ActionController::Parameters, Hash like {"9"=>"3"}, array of Answer-like objects, or array of pairs
  def initialize(answers = {})
    # ActionController::Parameters -> Hash
    if defined?(ActionController::Parameters) && answers.is_a?(ActionController::Parameters)
      answers = answers.to_unsafe_h
    end

    if answers.is_a?(Hash)
      # normalize keys to strings and values to integers
      @answers_data = answers.transform_keys(&:to_s).transform_values { |v| v.to_i }
    elsif answers.respond_to?(:map)
      # handle array of Answer models or array of [question_id, score] pairs
      pairs = answers.map do |a|
        if a.respond_to?(:question_id)
          [ a.question_id.to_s, (a.score || a.value).to_i ]
        elsif a.is_a?(Array) && a.size == 2
          [ a[0].to_s, a[1].to_i ]
        else
          nil
        end
      end.compact
      @answers_data = pairs.to_h
    else
      @answers_data = {}
    end
  end

  def result_code
    %w[A B C D].map { |cat| category_letter(cat) }.join
  end

  private

  def category_letter(category)
    score = @answers_data.sum do |question_id, score_value|
      q = Question.find_by(id: question_id.to_i)
      q && q.category == category ? score_value.to_i : 0
    end
    score < 13 ? "L" : "H"
  end
end
