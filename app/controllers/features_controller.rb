# frozen_string_literal: true
class FeaturesController < ApplicationController
  before_action :find_feature, only: %i[show edit destroy update]
  def index
    @features = Plan.find(params[:plan_id]).features
  end
  def new
    @plan = Plan.find(params[:plan_id])
    @feature = @plan.features.new
    authorize @feature
  end
  def show; end
  def edit
    authorize @feature
  end
  def create
    @plan = Plan.find(params[:plan_id])
    @feature = @plan.features.create(params_features)
    authorize @feature
    if @feature.save
      redirect_to plan_path(@plan)
    else
      render 'new'
    end
  end
  def update
    authorize @feature
    if @feature.update(params_features)
      redirect_to plan_features_path
    else
      render 'edit'
    end
  end
  def destroy
    id = @feature.plan_id
    if @feature.destroy
      redirect_to plan_features_path(id)
    else
      render 'show'
    end
  end
  private
  def find_feature
    @plan = Plan.find(params[:plan_id])
    @feature = @plan.features.find(params[:id])
  end
  def params_features
    params.require(:feature).permit(:name, :code, :unit_price, :max_unit_limit)
  end
end
