Grover.configure do |config|
  config.options = {
    format: "A4",
    margin: {
      top: "12mm",
      bottom: "12mm",
      left: "12mm",
      right: "12mm"
    },
    print_background: true,
    # Chromium のパスは環境変数で上書き可能（コンテナ環境向け）
    executable_path: ENV["GROVER_EXECUTABLE_PATH"].presence,
    launch_args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage"
    ],
    viewport: { width: 794, height: 1123 }
  }.compact
end
