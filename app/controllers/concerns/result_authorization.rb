# 診断結果(Result)とその配下(チャット・モルフ図鑑・PDF)へのアクセス制御。
# 診断を完了したセッションにだけ結果を見せる。それ以外には 403 ではなく 404 を返し、
# 連番IDから他人の診断結果の存在を推測できないようにする。
module ResultAuthorization
  extend ActiveSupport::Concern

  private

  def authorize_result!
    authorized_ids = session[:authorized_result_ids] || []
    raise ActiveRecord::RecordNotFound, "Result not found" unless authorized_ids.include?(@result.id)
  end
end
