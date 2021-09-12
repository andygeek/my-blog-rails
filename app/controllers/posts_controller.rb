class PostsController < ApplicationController

  # Sirve para ejecutar una accion antes de entrar al controlador
  # Cuando creamos una accion que puede modificar el comportamiento de un request usamos el !
  # Aqui lo usamos en el authenticate_user.
  # y luego usamos el only para decir que solo debe ser ejecutado antes de un create y un update
  # Esto lo implementaremos al finla
  before_action :authenticate_user!, only: [:create, :update] 

  # Manejo de excepciones en rails
  # Despues de rescue_from usa el valor que obtienes en la consola luego de ejecutar rspec
  # o cualquier otra excepcion que quieras validar
  # El orden en el que se colocan las excepciones es muy importante
  # el que está más abajo tiene mayor prioridad, es decir si Exception estaria más abajo
  # este tendria prioridad dobre un ActiveRecord que encuentre
  rescue_from Exception do |e|
    # log.error "#{e.message}"  En produccion tendriamos esto
    render json: {error: e.message}, status: :internal_error
  end
  
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: {error: e.message}, status: :unprocessable_entity
  end

  # GET /post
  def index
    @posts = Post.where(published: true)
    if !params[:search].nil? && params[:search].present?
      @posts = PostsSearchService.search(@posts, params[:search])
    end
    render json: @posts, status: :ok
  end

  # GET /post/{id}
  def show
    @post = Post.find(params[:id])
    render json: @post, status: :ok
  end

  # POST /posts
  def create
    @post = Post.create!(create_params)
    render json: @post, status: :ok
  end

  # PUT /posts/{id}
  def update
    @post = Post.find(params[:id])
    @post.update!(update_params)
    render json: @post, status: :ok
  end

  # En rails se tiene que implementar los parametros que recibirán las rutas
  # de la siguiente manera
  private

  def create_params
    params.require(:post).permit(:title, :content, :published, :user_id)
  end

  def update_params
    params.require(:post).permit(:title, :content, :published)
  end

  def authenticate_user! 
    # Bearer xxxx
    token_regex = /Bearer (\w+)/ 
    # leer header de auth
    headers = request.headers
    # verificar que sea valido
    if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
      token = headers['Authorization'].match(token_regex)[1]
      # devemos verificar que corresponda a un usuario
      # en ruby toda variable tiene en valor truthy y falsy
      # la siguiente expresion si se puede verificar
      # Current nos ayuda a guardar el usuario para que sea accesible en cualquier contexto de la app
      if( Current.user = User.find_by_auth_token(token) )
        return
      end
    end
    render json: {error: 'Unauthorized'}, status: :unauthorized
  end
end