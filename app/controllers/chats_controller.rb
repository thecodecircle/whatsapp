class ChatsController < ApplicationController
  before_action :set_chat, only: %i[ show edit update destroy ]

  # GET /chats or /chats.json
  def index
    @chats = Chat.all
  end

  # GET /chats/1 or /chats/1.json
  def show
		@people = @chat.people.order(messages: :desc)
  end

  # GET /chats/new
  def new
    @chat = Chat.new
  end

  # GET /chats/1/edit
  def edit
  end

  # POST /chats or /chats.json
  def create
    @chat = Chat.new
		file = params[:chat][:file]
		@chat.title = file.original_filename.delete_suffix(".txt")
    respond_to do |format|
      if @chat.save
				people = {}
				indexes_to_reject = [0,1,2]
				File.open(file, "r").each_line.with_index do |line, index|
					next if index == 0
					name = ''
					words = line.split(" ")
					if (Date.strptime(words[0].delete_suffix(","), "%d.%m.%Y") rescue false) && (Time.strptime(words[1], '%H:%M') rescue false) && words[2] == "-"
						words = words.reject.each_with_index{|w, ix| indexes_to_reject.include? ix }
						next unless words.join.include?(":")
						words.each do |word|
							name = name + ' ' + word
							if word.include?(":")
								break
							end
						end
						name.delete_suffix!(':')
						if people[name]
							people[name] = people[name] + 1
						else
							people[name] = 1
						end
					end
				end
				people.each do |key, value|
					Person.create(name: key, messages: value, chat_id: @chat.id)
				end
				if cookies[:chats].present?
					chats = JSON.parse(cookies[:chats])
					chats << @chat.id
					cookies.permanent[:chats] = JSON.generate(chats)
				else
					cookies.permanent[:chats] = JSON.generate([@chat.id])
				end
        format.html { redirect_to @chat, notice: "Chat was successfully created." }
        format.json { render :show, status: :created, location: @chat }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chats/1 or /chats/1.json
  def update
    respond_to do |format|
      if @chat.update(chat_params)
        format.html { redirect_to @chat, notice: "Chat was successfully updated." }
        format.json { render :show, status: :ok, location: @chat }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chats/1 or /chats/1.json
  def destroy
    @chat.destroy
    respond_to do |format|
      format.html { redirect_to chats_url, notice: "Chat was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = Chat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def chat_params
      params.require(:chat).permit(:title)
    end
end
