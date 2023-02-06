class OpenaiEmbedding
  DOC_EMBEDDINGS_MODEL = "text-search-curie-doc-001"
  QUERY_EMBEDDINGS_MODEL = "text-search-curie-query-001"

  def get_doc_embedding(text)
    get_embedding(text, DOC_EMBEDDINGS_MODEL)
  end

  def get_query_embedding(question)
    get_embedding(question, QUERY_EMBEDDINGS_MODEL)
  end

  # Get an embedding vector from OpenAI API
  def get_embedding(text, model)
    response = OpenAI::Client.new.embeddings(
      parameters: {
        model: model,
        input: text
      }
    )
    # this is a 4096 element array, is this always true?
    response["data"][0]["embedding"]
  end
end