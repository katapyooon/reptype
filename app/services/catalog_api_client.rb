# 図鑑API(reptype-catalog-api)を呼び出すクライアント
class CatalogApiClient
  class Error < StandardError; end
  class NotFound < Error; end

  BASE_URL = ENV.fetch("CATALOG_API_URL", "http://localhost:8080")
  OPEN_TIMEOUT = 2
  READ_TIMEOUT = 2

  class << self
    def list_morphs
      get("/api/v1/morphs")["morphs"]
    end

    def find_morph(code)
      get("/api/v1/morphs/#{ERB::Util.url_encode(code)}")
    rescue NotFound
      nil
    end

    private

    def get(path)
      uri = URI.join(BASE_URL, path)

      response = Net::HTTP.start(uri.host, uri.port,
                                  use_ssl: uri.scheme == "https",
                                  open_timeout: OPEN_TIMEOUT,
                                  read_timeout: READ_TIMEOUT) do |http|
        http.get(uri)
      end

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      when Net::HTTPNotFound
        raise NotFound, "#{path} not found"
      else
        raise Error, "unexpected response #{response.code} from #{path}"
      end
    rescue Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, SocketError => e
      raise Error, "failed to reach catalog API: #{e.message}"
    end
  end
end
