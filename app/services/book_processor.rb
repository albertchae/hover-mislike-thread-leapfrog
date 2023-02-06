class BookProcessor
  def initialize(pdf_path)
    @pdf_path = pdf_path
  end
  def call
    puts @pdf_path

  end
end