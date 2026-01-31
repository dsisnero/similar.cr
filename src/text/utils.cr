module Similar::Text
  # Splits a string into lines with newlines attached.
  def self.tokenize_lines(str : String) : Array(String)
    result = [] of String
    start = 0
    i = 0

    while i < str.bytesize
      char = str.char_at(i)
      if char == '\r'
        if i + 1 < str.bytesize && str.char_at(i + 1) == '\n'
          # CRLF
          result << str[start..i + 1]
          i += 2
          start = i
        else
          # CR alone
          result << str[start..i]
          i += 1
          start = i
        end
      elsif char == '\n'
        result << str[start..i]
        i += 1
        start = i
      else
        i += char.bytesize
      end
    end

    if start < str.bytesize
      result << str[start..]
    end

    result
  end

  # Splits a string into words and whitespace.
  def self.tokenize_words(str : String) : Array(String)
    result = [] of String
    i = 0

    while i < str.bytesize
      char = str.char_at(i)
      if char.whitespace?
        start = i
        while i < str.bytesize
          next_char = str.char_at(i)
          break unless next_char.whitespace?
          i += next_char.bytesize
        end
        result << str[start...i]
      else
        start = i
        while i < str.bytesize
          next_char = str.char_at(i)
          break if next_char.whitespace?
          i += next_char.bytesize
        end
        result << str[start...i]
      end
    end

    result
  end

  # Splits a string into characters (UTF-8 aware).
  def self.tokenize_chars(str : String) : Array(String)
    result = [] of String
    str.each_char do |char|
      result << char.to_s
    end
    result
  end

  # Basic Unicode word tokenization using character categories.
  def self.tokenize_unicode_words(str : String) : Array(String)
    result = [] of String
    i = 0

    while i < str.bytesize
      char = str.char_at(i)
      category = char_category(char)
      start = i

      while i < str.bytesize
        next_char = str.char_at(i)
        break if char_category(next_char) != category
        i += next_char.bytesize
      end

      result << str[start...i]
    end

    result
  end

  # Basic grapheme tokenization (treats each character as a grapheme).
  def self.tokenize_graphemes(str : String) : Array(String)
    # In a real implementation, this would handle combining characters
    tokenize_chars(str)
  end

  # Checks if a string ends with a newline.
  def self.ends_with_newline(str : String) : Bool
    str.ends_with?('\n') || str.ends_with?('\r')
  end

  private def self.char_category(char : Char) : Symbol
    if char.letter? || char.number?
      :alphanumeric
    elsif char.whitespace?
      :whitespace
    elsif char.punctuation?
      :punctuation
    else
      :other
    end
  end
end
