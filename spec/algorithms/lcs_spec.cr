require "../spec_helper"

describe Similar::Algorithms::Lcs do
  it "test_diff" do
    a = [0, 1, 2, 3, 4]
    b = [0, 1, 2, 9, 4]

    d = Similar::Algorithms::Replace.new(Similar::Algorithms::Capture.new)
    Similar::Algorithms.diff_slices(Similar::Algorithm::Lcs, d, a, b)
    ops = d.inner.ops

    ops.size.should eq(3)
    
    ops[0].should be_a(Similar::DiffOp::Equal)
    ops[0].as(Similar::DiffOp::Equal).old_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).new_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).len.should eq(3)

    ops[1].should be_a(Similar::DiffOp::Replace)
    ops[1].as(Similar::DiffOp::Replace).old_index.should eq(3)
    ops[1].as(Similar::DiffOp::Replace).old_len.should eq(1)
    ops[1].as(Similar::DiffOp::Replace).new_index.should eq(3)
    ops[1].as(Similar::DiffOp::Replace).new_len.should eq(1)

    ops[2].should be_a(Similar::DiffOp::Equal)
    ops[2].as(Similar::DiffOp::Equal).old_index.should eq(4)
    ops[2].as(Similar::DiffOp::Equal).new_index.should eq(4)
    ops[2].as(Similar::DiffOp::Equal).len.should eq(1)
  end

  it "test_contiguous" do
    a = [0, 1, 2, 3, 4, 4, 4, 5]
    b = [0, 1, 2, 8, 9, 4, 4, 7]

    d = Similar::Algorithms::Replace.new(Similar::Algorithms::Capture.new)
    Similar::Algorithms.diff_slices(Similar::Algorithm::Lcs, d, a, b)
    ops = d.inner.ops

    ops.size.should eq(4)
    
    ops[0].should be_a(Similar::DiffOp::Equal)
    ops[0].as(Similar::DiffOp::Equal).old_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).new_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).len.should eq(3)

    ops[1].should be_a(Similar::DiffOp::Replace)
    ops[1].as(Similar::DiffOp::Replace).old_index.should eq(3)
    ops[1].as(Similar::DiffOp::Replace).old_len.should eq(2)
    ops[1].as(Similar::DiffOp::Replace).new_index.should eq(3)
    ops[1].as(Similar::DiffOp::Replace).new_len.should eq(2)

    ops[2].should be_a(Similar::DiffOp::Equal)
    ops[2].as(Similar::DiffOp::Equal).old_index.should eq(5)
    ops[2].as(Similar::DiffOp::Equal).new_index.should eq(5)
    ops[2].as(Similar::DiffOp::Equal).len.should eq(2)

    ops[3].should be_a(Similar::DiffOp::Replace)
    ops[3].as(Similar::DiffOp::Replace).old_index.should eq(7)
    ops[3].as(Similar::DiffOp::Replace).old_len.should eq(1)
    ops[3].as(Similar::DiffOp::Replace).new_index.should eq(7)
    ops[3].as(Similar::DiffOp::Replace).new_len.should eq(1)
  end

  it "test_same" do
    a = [0, 1, 2, 3, 4, 4, 4, 5]
    b = [0, 1, 2, 3, 4, 4, 4, 5]

    d = Similar::Algorithms::Capture.new
    Similar::Algorithms.diff_slices(Similar::Algorithm::Lcs, d, a, b)
    ops = d.ops

    ops.size.should eq(1)
    ops[0].should be_a(Similar::DiffOp::Equal)
    ops[0].as(Similar::DiffOp::Equal).old_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).new_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).len.should eq(8)
  end

  it "test_pat" do
    a = [0, 1, 3, 4, 5]
    b = [0, 1, 4, 5, 8, 9]

    d = Similar::Algorithms::Capture.new
    Similar::Algorithms.diff_slices(Similar::Algorithm::Lcs, d, a, b)
    ops = d.ops

    ops.size.should eq(5)
    ops[0].should be_a(Similar::DiffOp::Equal)
    ops[0].as(Similar::DiffOp::Equal).old_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).new_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).len.should eq(2)

    ops[1].should be_a(Similar::DiffOp::Delete)
    ops[1].as(Similar::DiffOp::Delete).old_index.should eq(2)
    ops[1].as(Similar::DiffOp::Delete).old_len.should eq(1)
    ops[1].as(Similar::DiffOp::Delete).new_index.should eq(2)

    ops[2].should be_a(Similar::DiffOp::Equal)
    ops[2].as(Similar::DiffOp::Equal).old_index.should eq(3)
    ops[2].as(Similar::DiffOp::Equal).new_index.should eq(2)
    ops[2].as(Similar::DiffOp::Equal).len.should eq(1)

    ops[3].should be_a(Similar::DiffOp::Equal)
    ops[3].as(Similar::DiffOp::Equal).old_index.should eq(4)
    ops[3].as(Similar::DiffOp::Equal).new_index.should eq(3)
    ops[3].as(Similar::DiffOp::Equal).len.should eq(1)

    ops[4].should be_a(Similar::DiffOp::Insert)
    ops[4].as(Similar::DiffOp::Insert).old_index.should eq(5)
    ops[4].as(Similar::DiffOp::Insert).new_index.should eq(4)
    ops[4].as(Similar::DiffOp::Insert).new_len.should eq(2)
  end

  it "test_bad_range_regression" do
    d = Similar::Algorithms::Capture.new
    Similar::Algorithms.diff_slices(Similar::Algorithm::Lcs, d, [0], [0, 0])
    ops = d.ops

    ops.size.should eq(2)
    ops[0].should be_a(Similar::DiffOp::Equal)
    ops[0].as(Similar::DiffOp::Equal).old_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).new_index.should eq(0)
    ops[0].as(Similar::DiffOp::Equal).len.should eq(1)

    ops[1].should be_a(Similar::DiffOp::Insert)
    ops[1].as(Similar::DiffOp::Insert).old_index.should eq(1)
    ops[1].as(Similar::DiffOp::Insert).new_index.should eq(1)
    ops[1].as(Similar::DiffOp::Insert).new_len.should eq(1)
  end


end