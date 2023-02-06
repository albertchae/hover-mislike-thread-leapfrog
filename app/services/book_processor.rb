class BookProcessor
  def initialize(pdf_path)
    @pdf_path = pdf_path
    @tokenizer = Tokenizers.from_pretrained("gpt2")
  end
  def call
    book = PDF::Reader.new(@pdf_path)

    ascii_encoding_options = {
      invalid: :replace,  # Replace invalid byte sequences
      undef:   :replace,  # Replace anything not defined in ASCII
      replace: ''         # Use a blank for those replacements
    }

    # Parse book contents into dataframe
    pages = book.pages.map do |page|

      processed_page_text = page.text.
        gsub("\n", " ").                                         # replace newlines with spaces
        gsub(/\s+/, " ").                                        # replace multiple spaces with a single space
        encode(Encoding.find('ASCII'), **ascii_encoding_options) # encode to ascii because pdf-reader is spitting
                                                                 # out characters like ▯ and OpenAI embeddings are
                                                                 # behaving weirdly with them
      {
        title: "Page #{page.number}",
        content: processed_page_text,
        tokens: @tokenizer.encode(processed_page_text, add_special_tokens: false).tokens.count + 4
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