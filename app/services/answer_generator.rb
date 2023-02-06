require 'matrix'

class AnswerGenerator
  def answer_question(question)
    # 1. add ? if needed
    question = add_question_mark_if_necessary(question)

    # 2. look up question in cache, return cached answer if it exists
    possible_cached_question = Question.find_by(question: question)
    return possible_cached_question.answer if possible_cached_question.present?

    # 3. load pregenerated embeddings to use in constructing prompt
    question_embedding_vector = Vector.elements(OpenaiEmbedding.new.get_query_embedding(question))
    book_embeddings_df = Rover.read_csv('book.pdf.embeddings.csv')
    book_pages_df = Rover.read_csv('book.pdf.pages.csv')

    # 4. compute similarity of question with book text to get context
    relevant_book_sections = BookSimilarity.new(book_embeddings_df).relevant_sections(question_embedding_vector, book_pages_df)

    # 5. construct prompt using context + hardcoded questions and answers
    prompt = PromptTemplater.new.construct_prompt(question, relevant_book_sections)
    Rails.logger.info("QUESTION: #{question}")
    Rails.logger.info("PROMPT: #{prompt}")

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
    Rails.logger.info("ANSWER: #{answer}")

    # 7. cache question and answer
    Question.create(question: question, answer: answer)

    # 8. return answer
    answer
  end

  private

  def add_question_mark_if_necessary(question)
    return question if question.ends_with?('?')
    question + '?'
  end

end