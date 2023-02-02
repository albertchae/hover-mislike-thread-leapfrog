class AnswerGenerator
  def answer_question(question)
    # 1. add ? if needed
    question = add_question_mark_if_necessary(question)

    # 2. look up question in cache, return cached answer if it exists
    # 3. load pregenerated embeddings to use in constructing prompt
    # 4. compute similarity of question with book text to get context
    # 5. construct prompt using context + hardcoded questions and answers
    prompt = PromptTemplater.new.construct_prompt(question)
    # 6. send prompt to completions API for answer
    response = OpenAI::Client.new.completions(
      parameters: {
        prompt: prompt,
        # We use temperature of 0.0 because it gives the most predictable, factual answer.
        temperature: 0.0,
        max_tokens: 150,
        model: "text-davinci-003"
      })
    answer = response["choices"][0]["text"].strip
    # 7. cache question and answer
    # 8 return answer
    answer
  end

  private

  def add_question_mark_if_necessary(question)
    return question if question.ends_with?('?')
    question + '?'
  end

end