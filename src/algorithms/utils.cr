module Similar::Algorithms
  # Utility function to check if a range is empty.
  def self.is_empty_range(range : Range(Int32, Int32)) : Bool
    range.begin >= range.end
  end

  # Given two lookups and ranges calculates the length of the common prefix.
  def self.common_prefix_len(old, old_range : Range(Int32, Int32), new, new_range : Range(Int32, Int32)) : Int32
    return 0 if is_empty_range(old_range) || is_empty_range(new_range)

    count = 0
    old_idx = old_range.begin
    new_idx = new_range.begin

    while old_idx < old_range.end && new_idx < new_range.end
      break unless old[old_idx] == new[new_idx]
      count += 1
      old_idx += 1
      new_idx += 1
    end

    count
  end

  # Given two lookups and ranges calculates the length of common suffix.
  def self.common_suffix_len(old, old_range : Range(Int32, Int32), new, new_range : Range(Int32, Int32)) : Int32
    return 0 if is_empty_range(old_range) || is_empty_range(new_range)

    count = 0
    old_idx = old_range.end - 1
    new_idx = new_range.end - 1

    while old_idx >= old_range.begin && new_idx >= new_range.begin
      break unless old[old_idx] == new[new_idx]
      count += 1
      old_idx -= 1
      new_idx -= 1
    end

    count
  end

  # Represents an item in the vector returned by `unique`.
  #
  # It compares like the underlying item does it was created from but
  # carries the index it was originally created from.
  class UniqueItem(T)
    getter lookup : T
    getter index : Int32

    def initialize(@lookup : T, @index : Int32)
    end

    # Returns the value.
    def value
      @lookup[@index]
    end

    # Returns the original index.
    def original_index : Int32
      @index
    end

    def ==(other : UniqueItem) : Bool
      value == other.value
    end

    def_equals_and_hash @lookup, @index
  end

  # Returns only unique items in the sequence as vector.
  #
  # Each item is wrapped in a `UniqueItem` so that both the value and the
  # index can be extracted.
  def self.unique(lookup, range : Range(Int32, Int32))
    # Return empty array if range is empty
    return [] of UniqueItem(typeof(lookup)) if is_empty_range(range)

    # Create a hash map to track seen items
    seen = Hash(typeof(lookup[range.begin]), Int32?).new
    result = [] of UniqueItem(typeof(lookup))

    range.each do |index|
      item = lookup[index]
      case seen[item]?
      when nil
        # First time seeing this item
        seen[item] = index
      when Int32
        # Second time seeing this item, mark as non-unique
        seen[item] = nil
      else # nil
        # Already marked as non-unique, do nothing
      end
    end

    # Collect unique items and sort by original index
    seen.each do |_, index|
      if index
        result << UniqueItem.new(lookup, index)
      end
    end

    result.sort_by!(&.original_index)
    result
  end
end
