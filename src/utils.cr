require "./types"

module Similar::Utils
  # Remaps token slice ranges back to the original source.
  struct SliceRemapper(T)
    @source : T
    @indexes : Array(Range(Int32, Int32))

    def initialize(@source : T, slices : Array(T))
      indexes = [] of Range(Int32, Int32)
      offset = 0
      slices.each do |item|
        start = offset
        offset += item.size
        indexes << (start...offset)
      end
      @indexes = indexes
    end

    def slice(range : Range(Int32, Int32)) : T?
      return if range.begin >= range.end
      start_range = @indexes[range.begin]?
      end_range = @indexes[range.end - 1]?
      return unless start_range && end_range
      @source.slice(start_range.begin...end_range.end)
    end
  end

  # Remaps diff ops to slices of the original source strings.
  class TextDiffRemapper(T)
    @old : SliceRemapper(T)
    @new : SliceRemapper(T)

    def initialize(old_slices : Array(T), new_slices : Array(T), old : T, new : T)
      @old = SliceRemapper(T).new(old, old_slices)
      @new = SliceRemapper(T).new(new, new_slices)
    end

    def self.from_text_diff(diff : Similar::TextDiff(T), old : T, new : T) : self
      new(diff.old_tokens, diff.new_tokens, old, new)
    end

    def slice_old(range : Range(Int32, Int32)) : T?
      @old.slice(range)
    end

    def slice_new(range : Range(Int32, Int32)) : T?
      @new.slice(range)
    end

    def iter_slices(op : DiffOp) : Array({ChangeTag, T})
      tag, old_range, new_range = op.as_tag_tuple
      case tag
      when DiffTag::Equal
        value = @old.slice(old_range)
        raise "slice out of bounds" unless value
        [{ChangeTag::Equal, value}]
      when DiffTag::Insert
        value = @new.slice(new_range)
        raise "slice out of bounds" unless value
        [{ChangeTag::Insert, value}]
      when DiffTag::Delete
        value = @old.slice(old_range)
        raise "slice out of bounds" unless value
        [{ChangeTag::Delete, value}]
      when DiffTag::Replace
        old_value = @old.slice(old_range)
        new_value = @new.slice(new_range)
        raise "slice out of bounds" unless old_value && new_value
        [{ChangeTag::Delete, old_value}, {ChangeTag::Insert, new_value}]
      else
        [] of {ChangeTag, T}
      end
    end
  end
end
