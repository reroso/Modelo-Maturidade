module Appraisers
  class ExpertiseAreasController < ApplicationController
    before_action :authenticate_appraiser!

    def create
      @expertise_area = ExpertiseArea.new(expertise_area_params)
      
      if @expertise_area.save
        render json: { success: true, expertise_area: @expertise_area }
      else
        render json: { success: false, error: @expertise_area.errors.full_messages.join(", ") }
      end
    end

    private

    def expertise_area_params
      params.require(:expertise_area).permit(:name)
    end
  end
end
