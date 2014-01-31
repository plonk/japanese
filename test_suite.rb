#!/usr/bin/ruby
# encoding: utf-8

require 'open3'

def assert_reject(sentence)
    assert_status(sentence, 1)
end

def assert_accept(sentence)
    assert_status(sentence, 0)
end

def assert_status(sentence, expected_status)
  stdout, stderr, status =
    Open3.capture3("./sa", :stdin_data => sentence)

  if status.exitstatus != expected_status
    print "FAILED: #{sentence.inspect}\n"
    print "stdout:\n#{stdout}\n" if stdout != ""
    print "stderr:\n#{stderr}\n" if stderr != ""
  end
end

assert_accept "太郎 が 走る\n"
assert_accept "レディガガ か 画家 が 走る\n"
assert_accept "世界 の 新しい 人\n"
assert_accept "新しい 世界 の 人\n"
assert_reject "English will not be accepted\n"
assert_accept "レディガガ か 画家 か 蛾 が 我 が 強い\n"
assert_accept "レディガガ が 我 が 強い か 背が 高い か 性格 が 良い\n"
