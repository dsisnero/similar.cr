require "./mod"
require "../types"

module Similar::Algorithms
  # A `DiffHook` that reduces the size of diff by simplifying complex
  # change patterns.
  #
  # This hook attempts to reduce the number of diff operations by merging
  # adjacent operations and simplifying complex change patterns.  It's
  # primarily used internally to clean up diff results.
  class Compact(D, Old, New) < DiffHook
    @d : D
    @ops : Array(DiffOp)
    @old : Old
    @new : New

    # Creates a new compact hook wrapping another hook.
    def initialize(@d : D, @old : Old, @new : New)
      @ops = [] of DiffOp
    end

    # Extracts the inner hook.
    def inner : D
      @d
    end

    def equal(old_index : Int32, new_index : Int32, len : Int32) : Nil
      @ops << DiffOp::Equal.new(old_index, new_index, len)
    end

    def delete(old_index : Int32, old_len : Int32, new_index : Int32) : Nil
      @ops << DiffOp::Delete.new(old_index, old_len, new_index)
    end

    def insert(old_index : Int32, new_index : Int32, new_len : Int32) : Nil
      @ops << DiffOp::Insert.new(old_index, new_index, new_len)
    end

    def replace(old_index : Int32, old_len : Int32, new_index : Int32, new_len : Int32) : Nil
      @ops << DiffOp::Replace.new(old_index, old_len, new_index, new_len)
    end

    def finish : Nil
      # TODO: implement cleanup_diff_ops
      @ops.each do |op|
        op.apply_to_hook(@d)
      end
      @d.finish
    end

    # Extracts the inner hook.
    def into_inner : D
      @d
    end
  end
end
