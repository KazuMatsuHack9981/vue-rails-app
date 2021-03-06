module Api
  class CommandController < ApplicationController
    require 'zip'

    def index
      @commands = Command.all
    end

    def show
      @command = Command.find(params[:id])
      @command_file = @command.command_file
      @zipdata = @command_file.zipdata
      @unzippeddata = unzip_file(@zipdata)
      @filetree = json_file_tree(@unzippeddata.first)
      @filedatas = json_file_data(@unzippeddata)
      @index_url = command_pages_path
      @user = @command.user
    end

    def new
      @genres = Genre.all
      @command_types = CommandType.all
    end

    def create
      params[:zipdata] = params[:zipdata].tempfile.read
      @command = Command.new(command_create_params)
      @command.user_id = current_user.id
      @command.build_command_file

      @command.command_file.filename = params[:filename]
      @command.command_file.zipdata = params[:zipdata]
      @command.command_file.filesize = @command.command_file.zipdata.size

      if @command.save && @command.command_file.save
        redirect_to command_pages_path
      else
        response_bad_request(@command)
      end
    end

    def update
      @command = current_user.command.find(params[:id])
      @command.update(command_update_params)
      response_bad_request(@command) unless @command.save
    end

    def destroy
      @command = current_user.command.find(params[:id])
      response_bad_request(@command) unless @command.destroy
    end

    private

    def command_create_params
      params.permit(:title, :description, :genre_id, :command_type_id, :command_file_attributes)
    end

    def command_update_params
      params.permit(:title, :description, :genre_id, :command_type_id)
    end

    def unzip_file(zipdata)
      files = []
      datas = []
      ::Zip::File.open_buffer(zipdata) do |ar|
        ar.each do |entry|
          unless entry.name[-1] == '/'
            files.push(entry.name)
            datas.push(entry.get_input_stream.read)
          end
        end
      end

      [files, datas]
    end

    def json_file_tree(files)
      layerlist = files.map { |file_path| file_path.split('/') }
      structured_files = []
      layerlist.each do |layers|
        insert_file(layers, structured_files, '')
      end

      structured_files[0]
    end

    def insert_file(layers_to_insert, current_directory, path_of_parent)
      return if layers_to_insert.empty?

      head = layers_to_insert.first
      tail = layers_to_insert.slice(1, layers_to_insert.length)
      path_of_head = path_of_parent + '/' + head

      target = current_directory.find { |el| el[:name] == head }
      unless target
        target = {
          name: head,
          isfile: tail.empty?,
          path: path_of_head,
          children: []
        }
        current_directory.push(target)
      end

      insert_file(tail, target[:children], path_of_head)
    end

    def json_file_data(unzippeddata)
      files, datas = unzippeddata
      files.map! { |path| '/' + path }
      datas.map! { |data| data.force_encoding('ISO-8859-1').encode('UTF-8') }
      Hash[*[files, datas].transpose.flatten]
    end
  end
end
