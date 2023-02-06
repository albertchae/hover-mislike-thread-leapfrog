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
        tokens: @tokenizer.encode(page_text_with_compressed_whitespace).tokens.count
      }
    end
    book_pages_df = Rover::DataFrame.new(pages)

    # Write book content CSV for use by askmybook application
    File.write("#{@pdf_path}.pages.csv", book_pages_df.to_csv)





  end
end