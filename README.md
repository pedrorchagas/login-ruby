
# Project Title

A brief description of what this project does and who it's for
# Sistema de login 
Um simples sistema de login feito em Ruby

## Porque eu fiz?
Uma ótima forma de aprender é praticando, por isso eu desenvolvi esse pequeno projeto para aprender tecnologias e práticas que todos sistemas de login deve ter.

## Funcionalidades
 - Login
 - Registro
 - Cache de sessões

## Tecnologias
 - Redis
 - MySql
 - Ruby
 - Html e CSS puros
 - Sinatra (gem do Ruby)

## Imagens do sistema
### Index - Página inicial
Eu não foquei muio no index, pois o sistema é apenas para práticar outras tecnologias.
![Index - Pagina inicial](https://github.com/pedrorchagas/login-ruby/blob/main/Images/Index.png)
### Área de registro dos usuários
Aqui é onde o usuário cria sua conta e informa algumas informações para uso do sistema.
![Area de registro](https://github.com/pedrorchagas/login-ruby/blob/main/Images/Registrar.png)
### Área de login
Aqui é onde o usuário faz o seu login, email e senha. 
OBS: No meio tempo que estava fazendo esse projeto, eu estudei um pouco sobre SQL injection e infelizmente o meu sistema estava vulnerável, mas trando a entrada de informações consegui mitigar essa falha.
![Area de login](https://github.com/pedrorchagas/login-ruby/blob/main/Images/Login.png)
### Index com o usuário logado
Quando o usuário faz o login, é salvo um UUID em um cookie e com esse cookie podemos modificar o conteúdo visto pelo usuário, pois puxamos suas informações do banco de dados.
![Index - Qunado logado](https://github.com/pedrorchagas/login-ruby/blob/main/Images/Logado.png)

### Outras informações não importantes
 - O sistema de cache tambem ajuda a melhorar a velocidade do sistema, pois é salvo no Redis todas as informações mais acessadas (email, nome, etc) e cache e o cookie de login expiram juntos, evitando sobrecarga no cache e aumentando a segurança com sessões limitadas.
