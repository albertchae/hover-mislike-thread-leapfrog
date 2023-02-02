# frozen_string_literal: true

require 'rails_helper'

describe AnswerGenerator do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  context 'when passed a question' do
    it 'returns an answer' do
      expect(described_class.new.answer_question('do you work?')).to be_present
    end
  end
end
