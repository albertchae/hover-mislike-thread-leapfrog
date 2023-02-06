# Example usage: bin/rake process_book -- --pdf lecture1.pdf
task :process_book => [:environment] do |_t, _args|
  # boilerplate for parsing arguments https://www.seancdavis.com/posts/4-ways-to-pass-arguments-to-a-rake-task/
  options = {}
  opts = OptionParser.new
  opts.banner = "Usage: rake process_book [options]"
  opts.on("-p", "--pdf ARG", String) { |pdf| options[:pdf] = pdf}
  args = opts.order!(ARGV) {}
  opts.parse!(args)

  BookProcessor.new(options[:pdf]).call
end
