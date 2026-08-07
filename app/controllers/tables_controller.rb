class TablesController < ApplicationController
  def index
    @tables = DiningTable.active
  end
end
