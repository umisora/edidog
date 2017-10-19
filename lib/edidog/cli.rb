require 'edidog'
require 'thor'
require 'dogapi'
require 'json'

module Edidog
  class CLI < Thor
    def initialize(*args)
      super
      api_key = ENV.fetch('DATADOG_API_KEY')
      app_key = ENV.fetch('DATADOG_APP_KEY')
      @dog = Dogapi::Client.new(api_key, app_key)

      # Get Dashboards
      @timeboards = []
      @screenboards = []
      dashs = @dog.get_dashboards()[1]
      dashs["dashes"].each {|dash|
         @timeboards << { "id" => "#{dash['id']}", "title" => "#{dash['title']}", "type" => "timeboard"}
      }

      screens = @dog.get_all_screenboards()[1]
      screens["screenboards"].each {|screen|
         @screenboards << { "id" => "#{screen['id']}", "title" => "#{screen['title']}", "type" => "screenboard"}
      }

      @widget_type_whitelist = ["timeseries"]
    end

    desc "create <dashboard_name> <graph_id>,... -D <description> -V <tag_name>:<tag_value> ...", "create new dashboard with specify graph"
    option :description, :type => :string, :aliases => :D
    option :variables, :type => :hash , :aliases => :V
    def create(dashboard_name,ids)
      # set args
      graph_ids = ids.split(",").each.map(&:to_i)

      # default template valiable
      default_valiable_env = { "name" => "env", "prefix" => "env", "default" => "prod" }
      default_valiable_application = { "name" => "application", "prefix" => "application", "default" => "*" }
      default_valiable_service = { "name" => "service", "prefix" => "service", "default" => "*" }
      default_valiable_scope = { "name" => "scope" }
      default_valiables = [default_valiable_env, default_valiable_application, default_valiable_service, default_valiable_scope]

      # dashboard info
      title = dashboard_name
      description = "" + options[:description]
      variables = options[:variables]
      graphs = []
      template_variables = default_valiables

      # Get Graph Data
      begin
        File.foreach('tmp/graphs.txt') do |line|
          graph = JSON.parse(line)
          graphs << graph['definition'] if graph_ids.include?(graph['id']) 
        end

        # 例外は小さい単位で捕捉する
        rescue SystemCallError => e
          puts %Q(class=[#{e.class}] message=[#{e.message}])
        rescue IOError => e
          puts %Q(class=[#{e.class}] message=[#{e.message}])
      end

      # Set Custom Template Valiable 
      variables.each {|tag_name, tag_value|
        valiable = { "name" => "#{tag_name}", "prefix" => "#{tag_name}", "default" => "#{tag_value}" }
        template_variables << valiable       
      } if variables

      # Create Dashboard
      response = @dog.create_dashboard(title, description, graphs, template_variables)
      puts response[0]
    end

    desc "list board|graph -B board_id[ ...]", "View list bards or list graphs"
    option :boards, :type => :array, :aliases => :B
    def list(type)
      # > edidog list board
      if type.eql?("board") then
        puts "## Timeboard"
        @timeboards.each {|timeboard|
          puts "#{timeboard['id']} : #{timeboard['title']}"
        }
        puts "## Screenboard"
        @screenboards.each {|screenboard|
          puts "#{screenboard['id']} : #{screenboard['title']}"
        }

        # > edidog list graph
      elsif type.eql?("graph") then
        graph_id = 0
        graph_definitions = []
        board_ids = options[:boards]
        if board_ids then
          board_ids.each {|board_id|
            if ! @timeboards.select { |timeboard| timeboard['id'] == board_id }.empty? then
              dash = @dog.get_dashboard(board_id)[1]
              dash["dash"]["graphs"].each {|graph|
                graph_id = graph_id + 1
                graph_title = graph['title']
                puts "#{graph_id} : - #{graph_title} -"
                graph_definition = JSON.generate({ id: graph_id, title:graph_title, definition: graph })
                graph_definitions << graph_definition
              } if dash["dash"]["graphs"]

            board_title = dash["dash"]["title"]

            elsif ! @screenboards.select { |screenboard| screenboard['id'] == board_id }.empty? then
              dash = @dog.get_screenboard(board_id)[1]
              dash["widgets"].each {|widget|
                widget_type = widget['type']
                next unless @widget_type_whitelist.include?(widget_type)

                graph_id = graph_id + 1
                if widget_type == "timeseries" then
                  graph_title = widget['title_text']
                  graph = {"definition" => {"events" => widget['tile_def']['events'], "requests"=> widget['tile_def']['requests'],"viz" => widget['tile_def']['viz']},"title" => widget['title_text']}
                  puts "#{graph_id} : - #{graph_title} -"
                end
                
                graph_definition = JSON.generate({ id: graph_id, title:graph_title, definition: graph })
                graph_definitions << graph_definition
                board_title = dash["board_title"]
              } if dash["widgets"]
  
            else
              puts "Can not find board id #{board_id}" 
              exit 9
            end
            puts "#{board_title}(#{board_id})"
          }

          File.open("tmp/graphs.txt", "w") do |f|
            f.puts(graph_definitions)
          end
        else
          puts "Not Yet"         
        end
      else 
        puts "Usage edidog list board / edidog list graph"
      end
    end
  end
end
