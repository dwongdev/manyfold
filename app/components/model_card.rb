# frozen_string_literal: true

class Components::ModelCard < Components::Base
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::LinkTo

  register_output_helper :status_badges
  register_output_helper :server_indicator

  def initialize(model:, can_edit: false, can_destroy: false)
    @model = model
    @can_destroy = can_destroy
    @can_edit = can_edit
  end

  def view_template
    div class: "col mb-4" do
      div class: "card preview-card" do
        div(class: "card-header position-absolute w-100 top-0 z-3 bg-body-secondary text-secondary-emphasis opacity-75") { server_indicator @model } if @model.remote?
        PreviewFrame(object: @model)
        div(class: "card-body") { info_row }
        actions
      end
    end
  end

  private

  def title
    div class: "card-title" do
      a "data-editable-field": "model[name]", "data-editable-path": model_path(@model), contenteditable: "plaintext-only", "data-controller": "editable", "data-action": "focus->editable#onFocus blur->editable#onBlur" do
        @model.name
      end
      Icon(icon: "explicit", label: Model.human_attribute_name(:sensitive)) if @model.sensitive
    end
  end

  def open_button
    if @model.remote?
      link_to @model.federails_actor.profile_url, {class: "btn btn-primary btn-sm", "aria-label": translate("components.model_card.open_button.label", name: @model.name)} do
        span { "⁂" }
        whitespace
        span { t("components.model_card.open_button.text") }
      end
    else
      link_to t("components.model_card.open_button.text"), @model, {class: "btn btn-primary btn-sm", "aria-label": translate("components.model_card.open_button.label", name: @model.name)}
    end
  end

  def credits
    ul class: "list-unstyled" do
      if @model.creator
        li do
          Icon icon: "person", label: Creator.model_name.human
          link_to @model.creator.name, @model.creator, "aria-label": [Creator.model_name.human, @model.creator.name].join(": ")
        end
      end
      if @model.collection
        li do
          Icon icon: "collection", label: @model.collection.model_name.human
          link_to @model.collection.name, @model.collection, "aria-label": [@model.collection.model_name.human, @model.collection.name].join(": ")
        end
      end
    end
  end

  def caption
    if @model.caption
      span class: "card-subtitle text-muted" do
        sanitize @model.caption
      end
    end
  end

  def info_row
    div class: "row" do
      div class: "col" do
        title
        caption
      end
      div class: "col-auto" do
        small do
          credits
        end
      end
    end
  end

  def actions
    div class: "card-footer" do
      div class: "row" do
        div class: "col" do
          open_button
          whitespace
          status_badges @model
        end
        div class: "col col-auto" do
          BurgerMenu do
            DropdownItem(icon: "pencil", label: t("components.model_card.edit_button.text"), path: edit_model_path(@model), aria_label: translate("components.model_card.edit_button.label", name: @model.name)) if @can_edit
            DropdownItem(icon: "trash", label: t("components.model_card.delete_button.text"), path: model_path(@model), method: :delete, aria_label: translate("components.model_card.delete_button.label", name: @model.name), confirm: translate("models.destroy.confirm")) if @can_destroy
            DropdownItem(icon: "flag", label: t("general.report", type: ""), path: new_model_report_path(@model)) if SiteSettings.multiuser_enabled?
          end
        end
      end
    end
  end
end
