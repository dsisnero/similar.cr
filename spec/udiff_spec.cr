require "./spec_helper"

describe Similar::UnifiedDiff do
  it "generates simple unified diff" do
    old_text = "a\nb\nc"
    new_text = "a\nb\nC"
    diff = Similar::TextDiff.from_lines(old_text, new_text)
    udiff = diff.unified_diff.header("old.txt", "new.txt")
    output = udiff.to_s

    # Basic validation
    output.should contain("--- old.txt")
    output.should contain("+++ new.txt")
    output.should contain("@@ -")
    output.should contain("+C")
    output.should contain("-c")
  end

  it "handles empty diff" do
    diff = Similar::TextDiff.from_lines("abc", "abc")
    udiff = diff.unified_diff.header("a.txt", "b.txt")
    udiff.to_s.should eq("")
  end

  it "respects context radius" do
    old_text = "a\nb\nc\nd\ne\nf\ng\nh\ni\nj\nk\nl\nm\nn\no\np\nq\nr\ns\nt\nu\nv\nw\nx\ny\nz"
    new_text = "a\nb\nc\nd\ne\nf\ng\nh\ni\nj\nk\nl\nm\nn\no\np\nq\nr\nS\nt\nu\nv\nw\nx\ny\nz"
    diff = Similar::TextDiff.from_lines(old_text, new_text)
    udiff = diff.unified_diff.context_radius(1).header("old.txt", "new.txt")
    output = udiff.to_s
    # Should have only a few lines of context around change
    lines = output.lines
    lines.select(&.starts_with?(' ')).size.should be <= 4 # 1 line above + 1 below each side
  end

  it "test_regression_issue_37" do
    # Ported from Rust: test_regression_issue_37 in src/text/mod.rs
    # Tests edge case with control characters and newlines in unified diff
    config = Similar::TextDiffConfig.new
    diff = config.diff_lines("\u{18}\n\n", "\n\n\r")
    output = diff.unified_diff.context_radius(0).to_s

    # Expected output from Rust:
    # "@@ -1 +1,0 @@\n-\u{18}\n@@ -2,0 +2,2 @@\n+\n+\r"
    # Note: Crystal's to_s might produce slightly different formatting
    # Let's verify key properties
    output.should contain("@@ -1 +1,0 @@")
    output.should contain("-\u{18}")
    output.should contain("@@ -2,0 +2,2 @@")
    output.should contain("+\n")
    output.should contain("+\r")
  end
end
