require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  FakeRag = Struct.new(:chunks) do
    def search(_question) = chunks
  end

  FakeChat = Struct.new(:answer) do
    def call(**) = answer.respond_to?(:call) ? answer.call : answer
  end

  setup do
    @result = results(:one)
  end

  test "create returns 200 with the answer" do
    as_authorized do
      with_services(chunks: [ :chunk ], answer: "ヒョウモントカゲモドキは夜行性だよ！") do
        post_question "夜行性ですか？"
      end
    end

    assert_response :ok
    assert_equal "ヒョウモントカゲモドキは夜行性だよ！", response.parsed_body["answer"]
  end

  test "create returns 200 with a fallback answer when no chunks match" do
    as_authorized do
      with_services(chunks: [], answer: "unused") do
        post_question "宇宙に行けますか？"
      end
    end

    assert_response :ok
    assert_equal "うーん、それはちょっとわからないな〜", response.parsed_body["answer"]
  end

  test "create returns 422 when the question is blank" do
    as_authorized { post_question "   " }

    assert_error :unprocessable_entity, "なにか質問してみてよ！"
  end

  test "create returns 422 when the question is too long" do
    as_authorized { post_question "あ" * (ChatsController::QUESTION_MAX_LENGTH + 1) }

    assert_error :unprocessable_entity, "質問は400文字以内にしてね！"
  end

  test "create returns 403 when the result is not authorized" do
    post_question "夜行性ですか？"

    assert_error :forbidden, "セッションが切れました。もう一度診断してください。"
  end

  test "create returns 404 when the result does not exist" do
    post result_chat_url(result_id: 0), params: { question: "夜行性ですか？" }, as: :json

    assert_error :not_found, "診断結果が見つかりませんでした。もう一度診断してください。"
  end

  test "create returns 503 when Bedrock is unavailable" do
    failing = -> { raise Aws::Errors::ServiceError.new(nil, "throttled") }

    as_authorized do
      with_services(chunks: [ :chunk ], answer: failing) do
        post_question "夜行性ですか？"
      end
    end

    assert_error :service_unavailable, "いまは答えられないみたい。少し待ってからまた聞いてね！"
  end

  test "show redirects to the result when not authorized" do
    get result_chat_url(@result)

    assert_redirected_to result_url(@result)
  end

  private

  def post_question(question)
    post result_chat_url(@result), params: { question: question }, as: :json
  end

  def assert_error(status, message)
    assert_response status
    assert_equal({ "code" => status.to_s, "message" => message }, response.parsed_body["error"])
  end

  # session[:authorized_result_ids] は実リクエストを経ないと書き込めないため、認可チェック自体を差し替える
  def as_authorized(&block)
    stub_instance_method(ChatsController, :authorize_result!, -> { }, &block)
  end

  # Bedrock を呼ばないよう RAG 検索と回答生成を差し替える
  # (stub_class_method は call を持つ値を呼び出すため、FakeChat は lambda で包んで返す)
  def with_services(chunks:, answer:, &block)
    fake_chat = FakeChat.new(answer)
    stub_class_method(RagSearchService, :new, FakeRag.new(chunks)) do
      stub_class_method(BedrockChatService, :new, ->(*) { fake_chat }, &block)
    end
  end
end
