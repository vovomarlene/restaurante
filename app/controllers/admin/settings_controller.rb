class Admin::SettingsController < Admin::BaseController
  def edit
    @setting = Setting.instance
  end

  def update
    @setting = Setting.instance

    if @setting.update(setting_params)
      redirect_to edit_admin_setting_path, notice: "Configurações salvas."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.expect(setting: [ :restaurant_name, :receipt_printer_name, :kitchen_printer_name, :default_service_fee_percent ])
  end
end
