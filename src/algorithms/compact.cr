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
      cleanup_diff_ops(@old, @new, @ops)
      @ops.each do |op|
        op.apply_to_hook(@d)
      end
      @d.finish
    end

    private def cleanup_diff_ops(old, new, ops : Array(DiffOp)) : Nil
      # Simplified cleanup: swap Insert and Delete when Insert comes before Delete
      i = 0
      while i < ops.size
        op = ops[i]
        if i > 0 && op.tag == DiffTag::Delete && ops[i - 1].tag == DiffTag::Insert
          # Swap Insert and Delete
          ops[i - 1], ops[i] = ops[i], ops[i - 1]
          i -= 1 if i > 1
        elsif i > 0 && op.tag == DiffTag::Insert && ops[i - 1].tag == DiffTag::Delete
          # Already Delete before Insert, good
        end
        i += 1
      end

      # Merge consecutive inserts or deletes
      i = 0
      while i < ops.size
        op = ops[i]
        if i > 0 && op.tag == ops[i - 1].tag
          case op.tag
          when DiffTag::Insert
            prev = ops[i - 1].as(DiffOp::Insert)
            curr = op.as(DiffOp::Insert)
            # Check if they are adjacent
            if prev.new_index + prev.new_len == curr.new_index && prev.old_index == curr.old_index
              # Merge
              ops[i - 1] = DiffOp::Insert.new(prev.old_index, prev.new_index, prev.new_len + curr.new_len)
              ops.delete_at(i)
              next
            end
          when DiffTag::Delete
            prev = ops[i - 1].as(DiffOp::Delete)
            curr = op.as(DiffOp::Delete)
            if prev.old_index + prev.old_len == curr.old_index && prev.new_index == curr.new_index
              ops[i - 1] = DiffOp::Delete.new(prev.old_index, prev.old_len + curr.old_len, prev.new_index)
              ops.delete_at(i)
              next
            end
          end
        end
        i += 1
      end
    end

    # Extracts the inner hook.
    def into_inner : D
      @d
    end
  end
end
