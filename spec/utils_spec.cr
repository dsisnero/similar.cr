require "./spec_helper"

describe Similar::Utils::SliceRemapper do
  it "remaps token ranges" do
    source = "foo bar baz"
    tokens = Similar::Text.tokenize_words(source)
    wrapped_source = Similar::StringWrapper.new(source)
    wrapped_tokens = tokens.map { |token| Similar::StringWrapper.new(token) }

    remapper = Similar::Utils::SliceRemapper(Similar::StringWrapper).new(
      wrapped_source,
      wrapped_tokens
    )

    remapper.slice(0...3).try(&.to_s).should eq("foo bar")
    remapper.slice(1...3).try(&.to_s).should eq(" bar")
    remapper.slice(0...1).try(&.to_s).should eq("foo")
    remapper.slice(0...5).try(&.to_s).should eq("foo bar baz")
    remapper.slice(0...6).should be_nil
  end
end
