require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test ".instance reuses the same singleton row instead of creating duplicates" do
    Setting.delete_all

    first_call = Setting.instance
    second_call = Setting.instance

    assert_equal first_call.id, second_call.id
    assert_equal 1, Setting.count
  end
end
