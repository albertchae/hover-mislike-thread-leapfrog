class BookProcessor
  def initialize(pdf_path)
    @pdf_path = pdf_path
    @tokenizer = Tokenizers.from_pretrained("gpt2")
  end
  def call
    book = PDF::Reader.new(@pdf_path)

    # Parse book contents into dataframe
    pages = book.pages.map do |page|
      # Replace newlines with spaces and replace multiple spaces with a single space
      page_text_with_compressed_whitespace = page.text.gsub("\n", " ").gsub(/\s+/, " ")
      {
        title: "Page #{page.number}",
        content: page_text_with_compressed_whitespace,
        tokens: @tokenizer.encode(page_text_with_compressed_whitespace).tokens.count + 4
      }
    end
    book_pages_df = Rover::DataFrame.new(pages)
    # discard pages that go over the embedding input token limit of 2046
    # https://platform.openai.com/docs/guides/embeddings/embedding-models
    book_pages_df = book_pages_df[book_pages_df[:tokens] < 2046]

    # Write book content CSV for use by askmybook application
    File.write("#{@pdf_path}.pages.csv", book_pages_df.to_csv)

    # Compute embeddings for each book page with OpenAI API and write to CSV for
    # similarity checking by application
    openai_embedding = OpenaiEmbedding.new
    embedding_csv_headers = ['title', *(0...4096).to_a]
    CSV.open("#{@pdf_path}.embeddings.csv", "wb") do |csv|
      csv << embedding_csv_headers
      book_pages_df.each_row do |page|
        page_embedding_array = openai_embedding.get_doc_embedding(page[:content])
        csv << [page[:title], *page_embedding_array]
      end
    end
  end
end