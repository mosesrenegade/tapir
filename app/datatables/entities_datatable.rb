class EntitiesDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Entities::Base.all.count,
      iTotalDisplayRecords: Entities::Base.all.count,
      aaData: data
    }
  end

private

  def data
    entities.map do |entity|
      [
        link_to(entity, "/entities/#{entity._id}")
      ]
    end
  end

  def entities
    @entities ||= fetch_entities
  end

  def fetch_entities
    # Fetch the correct objects

    if params[:sSearch].present?
      entities = Entities::Base.where( :name => /#{params[:sSearch]}/i ).order_by("#{sort_column} #{sort_direction}")
    else
      entities = Entities::Base.order_by("#{sort_column} #{sort_direction}")
    end
    
    # Page the objects if necessary
    entities = entities[start..(start + per_page)]

    entities
  end

  def start
    params[:iDisplayStart].to_i #/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 100
  end

  def sort_column
    columns = %w[ name ]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end