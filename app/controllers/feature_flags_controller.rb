class FeatureFlagsController < ApplicationController
  layout FeatureFlags.configuration.layout.downcase
  before_filter :load_features, :only => [:index,:create,:update,:destroy]
  before_filter :get_feature, :only => [:edit, :update, :destroy]

  def index
    authorize! :read, Feature
  end

  def new
    @feature = Feature.new
    authorize! :manage, Feature
  end

  def edit
    authorize! :manage, Feature
  end

  def create
    @feature = Feature.new(feature_params)
    respond_to do |format|
      if @feature.save
        flash[:notice] = "#{@feature.name} feature successfully created"
        format.html{
          redirect_to feature_flags_url
        }
      else
        flash[:error] = "#{@feature.name} feature could not be created"
        format.html{
          render :new
        }
      end
    end
    authorize! :manage, Feature
  end

  def enable_all
    FeatureFlags.enable_all
    authorize! :manage, Feature
  end

  def disable_all
    FeatureFlags.disable_all
    authorize! :manage, Feature
  end

  def update 
    enabled_all = params[:enable_all].present? ? enable_all : false
    disabled_all = params[:disable_all].present? ? disable_all : false

    respond_to do |format|
      if enabled_all || disabled_all || @feature.update_attributes(feature_params)  
        flash[:notice] = "#{@feature.name} feature successfully updated"
        format.html{
          redirect_to feature_flags_url
        }

        format.js{
          render :json => {:status => true, :message => flash[:notice]}
        }       
      else        
        flash[:error] = "#{@feature.name} feature could not be updated"
        format.html{
          redirect_to feature_flags_url
        }
        format.js{
          render :json => {:status => false, :message => flash[:error]}
        }       
      end     
    end
    authorize! :manage, Feature
  end

  def destroy
    respond_to do |format|
      if @feature.destroy
        flash[:notice] = "Feature successfully removed"
        format.html{
          redirect_to feature_flags_url
        }

        format.js{
          render :json => {:status => true, :message => flash[:notice]}
        }       
      else        
        flash[:error] = "This feature could not be removed"
        format.html{
          redirect_to feature_flags_url
        }
        format.js{
          render :json => {:status => false, :message => flash[:error]}
        }       
      end     
    end
    authorize! :manage, Feature
  end

  def load_features
    @features = Feature.all
  end

  private

    def get_feature
      @feature = Feature.find(params[:id])
    end

    def feature_params
      params.require(:feature).permit(:name, :status, :disable_all, :enable_all)
    end

end
