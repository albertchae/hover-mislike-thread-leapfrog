class QuestionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    render json: {answer_text: "you asked me " + params[:question_text]}, status: 200
  end
end
