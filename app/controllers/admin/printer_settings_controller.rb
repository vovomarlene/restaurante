class Admin::PrinterSettingsController < Admin::BaseController
  def edit
    @printer_setting = PrinterSetting.instance
  end

  def update
    @printer_setting = PrinterSetting.instance

    if @printer_setting.update(printer_setting_params)
      redirect_to edit_admin_printer_setting_path, notice: "Configuração de impressoras salva."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def printer_setting_params
    params.expect(printer_setting: [ :restaurant_name, :receipt_printer_name, :kitchen_printer_name ])
  end
end
