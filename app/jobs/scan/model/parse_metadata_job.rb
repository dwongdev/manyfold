class Scan::Model::ParseMetadataJob < ApplicationJob
  queue_as :scan
  unique :until_executed

  def perform(model_id)
    model = Model.find(model_id)
    return if model.remote?
    # Set tags and default files
    model.preview_file = model.model_files.min_by { |it| preview_priority(it) } unless model.preview_file
    if model.tags.empty?
      model.generate_tags_from_directory_name! if SiteSettings.model_tags_tag_model_directory_name
      if SiteSettings.model_tags_auto_tag_new.present?
        model.tag_list << SiteSettings.model_tags_auto_tag_new
      end
    end
    if !model.creator_id && SiteSettings.parse_metadata_from_path
      model.parse_metadata_from_path
    end
    model.save! # Problem check will run automatically after save
  end

  def preview_priority(file)
    return 0 if file.is_image?
    return 1 if file.is_renderable?
    100
  end
end
