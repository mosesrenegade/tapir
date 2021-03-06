require 'nokogiri'
require 'open-uri'
require 'cgi'

# Returns the name of this task.
def name
  "hoovers_company_search"
end

def pretty_name
  "Hoovers Search"
end

# Returns a string which describes this task.
def description
  "This task scrapes Hoovers and creates organizations for all companies found."
end

# Returns an array of valid types for this task
def allowed_types
  [Entities::SearchString]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
  self
end

# Default method, subclasses must override this
def run
  super

  # Wrap the whole thing in a begin, we could have URI's switched beneath us. 
  begin
    # Search URI
    search_uri = "http://www.hoovers.com/search/company-search-results/100005142-1.html?type=company&term=#{@entity.name}"

    # Open page & parse
    @task_logger.log "Using Company URI: #{search_uri}"
    doc = Nokogiri::HTML(open(search_uri, "User-Agent" => USER_AGENT_STRING))

    # Open the returned xhtml doc
    doc.xpath("//*[@class='company_name']").each do |xpath|

      # Construct the Company-specific URI's
      company_name = xpath.children.first['title']
      company_path = xpath.children.first['href']
      company_uri = "http://www.hoovers.com#{company_path}"
      @task_logger.log "Using Company search URI: #{company_uri}"

      # Create a new organization entity
      o = create_entity(Entities::Organization, { :name => company_name })

      # Queue a detailed search
      # TaskManager.instance.queue_task_run("hoovers_company_detail",o, {})

    end
  rescue Exception => e
    @task_logger.log_error "Caught Exception: #{e}"
  end
end

def cleanup
  super
end
