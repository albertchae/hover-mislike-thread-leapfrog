class AnswerGenerator
  def answer_question(question)
    # 1. add ? if needed
    # 2. look up question in cache, return cached answer if it exists
    # 3. load pregenerated embeddings to use in constructing prompt
    # 4. compute similarity of question with book text to get context
    # 5. construct prompt using context + hardcoded questions and answers
    # 6. send prompt to completions API for answer
    # 7. cache question and answer
    # 8 return answer
    "You asked me #{question}"
  end


end