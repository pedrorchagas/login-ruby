require 'sinatra'
require 'sqlite3'
require 'digest'
require 'json'
require 'redis'
require 'securerandom'


# docker start redis-stack-server <- para iniciar o redis caso ele não tenha iniciado
$redis = Redis.new(host: "localhost", port: 6379)

# Criação do banco de dados e criação da tabela usuários
$database = SQLite3::Database.new "database.db"
$database.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    username TEXT NOT NULL,
    birthday DATE NOT NULL
  );
SQL

def input_sanitize(input, mode = :other)
    input.strip!
    if mode == :email
        input.gsub!(/[^a-zA-Z0-9@._-]/, '')
    elsif mode == :name
        input.gsub!(/[^a-zA-ZÀ-ÿ' -]/, '')
    else
        input.gsub!(/[^[:alnum:]À-ÿ\s]/, '')
    end
    
    return input
end

def get_user(email, password_hash)
    email = input_sanitize(email, :email)

    login = $database.execute("SELECT * FROM users WHERE email = '#{email}' AND password_hash = '#{password_hash}' ")
    # id, email, password_hash, created, username, birthday
    #print login
    if login.empty?
        return false
    else
        user = {id: login[0][0], email: login[0][1], created: login[0][3], username: login[0][4], birthday: login[0][5]}
        return user
    end
end

set :public_folder, __dir__ + '/static'

# Página principal
get '/' do
    uuid = request.cookies["user"]
    
    # verifica se o usuário está logado
    unless uuid.nil?
        #@user = JSON.parse(cookie, symbolize_names: true)
        @user = $redis.hgetall(uuid)
    end
    
    erb :index
end

# Processamento de dados para o login dos usuários
get '/login' do
    uuid = request.cookies["user"]
    
    # verifica se o usuário está logado
    unless uuid.nil?
        #@user = JSON.parse(cookie, symbolize_names: true)
        @user = $redis.hgetall(uuid)
    end
    erb :login
end

post '/login' do
    email = params["email"]
    password = params["password"]

    password_hash = Digest::SHA256.hexdigest(password)

    
    @user = get_user(email, password_hash)

    unless @user
        print "erro"
        # caso ele for false isso irá acontecer
        return "erro"
    else
        print @user
        #response.set_cookie("user", value: @user.to_json, expires: Time.now + 3600)
        expire_time = 300
        uuid = SecureRandom.uuid
        response.set_cookie("user", value:  uuid, expires: Time.now + expire_time )
        
        # user = {id: login[0][0], email: login[0][1], created: login[0][3], username: login[0][4], birthday: login[0][5]}
        $redis.hset(uuid, "id", @user[:id])
        $redis.hset(uuid, "email", @user[:email])
        $redis.hset(uuid, "created", @user[:created])
        $redis.hset(uuid, "username", @user[:username])
        $redis.hset(uuid, "birthday", @user[:birthday])
        $redis.expire(uuid, expire_time)

        erb :login
    end
end

# -------- Processamento de dados para o registro dos usuários
get '/register' do
    erb :register
end

post '/register' do
    username = input_sanitize(params["username"], :name)
    birthday = params["birthday-date"]
    email = input_sanitize( params["email"], :email)
    senha_1 = params["password-1"]
    senha_2 = params["password-2"]

    #puts "email: #{email}, senha1: #{senha_1}, senha2: #{senha_2}, username: #{username}, birthday: #{birthday} "
    if senha_1 == senha_2
        
        password_hash = Digest::SHA256.hexdigest(senha_1)
        begin
            $database.execute("INSERT INTO users (email, password_hash, username, birthday) VALUES (?, ?, ?, ?)", [email, password_hash, username, birthday])
            @sucess = true
        rescue SQLite3::ConstraintException
            @user_exists = true
        rescue => e
            @fail = true
        end
        erb :register
    else
        @diferpassword = true
        erb :register
    end
end

# Processamento de dados para o logout do usuário
get '/logout' do
    uuid = request.cookies["user"]
    
    # verifica se o usuário está logado
    unless uuid.nil?
        #@user = JSON.parse(cookie, symbolize_names: true)
        @user = $redis.hgetall(uuid)
    end
    erb :logout
end

post '/logout' do
    response.delete_cookie('user')
    @sucess = true
    erb :logout
end

$redis.flushall