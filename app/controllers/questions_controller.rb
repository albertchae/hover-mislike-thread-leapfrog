class QuestionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    answer = ::AnswerGenerator.new.answer_question(params[:question_text])
    render json: {answer_text: answer}, status: 200
  end
end
