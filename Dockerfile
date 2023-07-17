FROM ruby:3.0.4

# Instalando as dependências do sistema
RUN apt-get update && apt-get install -y \
  ca-certificates \
  build-essential \
  curl \
  git \
  libssl-dev \
  zlib1g-dev \
  libpq-dev

# Instalando o Node.js
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

# Instalando o Yarn
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

# Definindo o diretório de trabalho
WORKDIR /app

# Copiando arquivos do projeto
COPY Gemfile ./
COPY Gemfile.lock ./
COPY . .

# Instalando as dependências as dependências
RUN gem install rails bundler
RUN bundle install
RUN npm install && \
  yarn
RUN gem install mailcatcher --no-document

# Expondo a porta do projeto
EXPOSE 1025
EXPOSE 1080
EXPOSE 3000

# Comando de inicialização
CMD ["bash", "-c", "rails db:create db:migrate && rails server -b 0.0.0.0 && mailcatcher && bundle exec sidekiq"]
