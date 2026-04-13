class BedrockEmbeddingService
  MODEL_ID = "amazon.titan-embed-text-v2:0"

  def initialize
    @client = Aws::BedrockRuntime::Client.new(region: ENV.fetch("AWS_REGION", "ap-northeast-1"))
  end

  def embed(text)
    response = @client.invoke_model(
      model_id: MODEL_ID,
      content_type: "application/json",
      accept: "application/json",
      body: { inputText: text }.to_json
    )
    JSON.parse(response.body.read)["embedding"]
  end
end
