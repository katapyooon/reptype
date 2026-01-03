class LikertController < ApplicationController
  def index
    @question = Question.all
  end
end
