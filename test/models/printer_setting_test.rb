require "test_helper"

class PrinterSettingTest < ActiveSupport::TestCase
  test ".instance reuses the same singleton row instead of creating duplicates" do
    PrinterSetting.delete_all

    first_call = PrinterSetting.instance
    second_call = PrinterSetting.instance

    assert_equal first_call.id, second_call.id
    assert_equal 1, PrinterSetting.count
  end
end
