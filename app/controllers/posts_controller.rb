class PostsController < ApplicationController

  # Sirve para ejecutar una accion antes de entrar al controlador
  # Cuando creamos una accion que puede modificar el comportamiento de un request usamos el !
  # Aqui lo usamos en el authenticate_user.
  # y luego usamos el only para decir que solo debe ser ejecutado antes de un create y un update
  # Esto lo implementaremos al finla
  before_action :authenticate_user!, only: [:create, :update] 
  # OJO: Le puse el show para que la prueba de show siempre pase, la otra serie haciendo que su published siempre sea true


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

  # Si te sale que no se reconoce el status code, es porque la excepcion lo la reconoce
  # en caso de que te devuelva un ActiveRecord::RecordNotFound esta nos e reconoce, por loq ue debemos agregar una excepcion
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: {error: e.message}, status: :not_found
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
    # Aqui debemos verificar que el post es publico
    # y si no es publico debemos verificar que el usuario esta authenticado
    if ( @post.published? || (Current.user && @post.user_id == Current.user.id) )
      render json: @post, status: :ok 
    else 
      render json: {error: 'Not Found'}, status: :not_found
    end
  end

  # POST /posts
  def create
    # Esto hace que el post pertenezca al usuario que se authentico
    @post = Current.user.posts.create!(create_params)
    render json: @post, status: :ok
  end

  # PUT /posts/{id}
  def update
    # Esto hace que el post a modificar pertenezca a ese usuario
    @post = Current.user.posts.find(params[:id])
    @post.update!(update_params)
    render json: @post, status: :ok
  end

  # En rails se tiene que implementar los parametros que recibirán las rutas
  # de la siguiente manera
  private

  def create_params
    params.require(:post).permit(:title, :content, :published, :id)
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