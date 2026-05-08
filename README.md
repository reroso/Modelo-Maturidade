# Modelo de Maturidade

Aplicação Ruby on Rails para avaliação e visualização do modelo de maturidade.

Este guia mostra, passo a passo, como subir o projeto em um Ubuntu limpo, sem Ruby, Rails, Node.js ou Yarn instalados.

## Versões usadas no projeto

- Ruby `2.7.0`
- Rails `6.0.4`
- SQLite3

## 1. Instalar dependências do sistema

Abra um terminal e execute:

```bash
sudo apt update
sudo apt install -y git curl gnupg2 build-essential libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libyaml-dev libgdbm-dev libncurses5-dev autoconf bison patch rustc pkg-config
```

## 2. Instalar o rbenv

O rbenv facilita instalar a versão exata do Ruby usada pelo projeto.

```bash
curl -fsSL https://raw.githubusercontent.com/rbenv/rbenv/master/install.sh | bash
curl -fsSL https://github.com/rbenv/ruby-build/archive/refs/heads/master.tar.gz | tar -xz -C ~/.rbenv/plugins
mv ~/.rbenv/plugins/ruby-build-master ~/.rbenv/plugins/ruby-build
```

Agora adicione o rbenv ao shell. Se você usa bash:

```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
source ~/.bashrc
```

Se você usa zsh, troque `~/.bashrc` por `~/.zshrc`.

## 3. Instalar o Ruby 2.7.0

```bash
rbenv install 2.7.0
rbenv global 2.7.0
ruby -v
```

O comando `ruby -v` deve mostrar algo como `ruby 2.7.0`.

## 4. Instalar o Bundler

```bash
gem install bundler
```

## 5. Instalar Node.js e Yarn

O projeto usa Webpacker, então precisa de Node.js e Yarn.

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g yarn
node -v
yarn -v
```

## 6. Baixar o projeto

Se você ainda não clonou o repositório, faça isso agora:

```bash
git clone <URL_DO_REPOSITORIO>
cd Modelo-Maturidade
```

Se você já está dentro da pasta do projeto, continue para o próximo passo.

## 7. Instalar as dependências Ruby

```bash
bundle install
```

## 8. Instalar as dependências JavaScript

```bash
yarn install
```

## 9. Preparar o banco de dados

O projeto usa SQLite, então não é preciso instalar um servidor de banco separado.

```bash
bundle exec rails db:create
bundle exec rails db:migrate
```

Se você quiser popular o banco com dados iniciais e houver seeds no projeto, rode:

```bash
bundle exec rails db:seed
```

## 10. Subir a aplicação

Agora inicie o servidor Rails:

```bash
bundle exec rails s
```

Abra o navegador em:

```text
http://localhost:3000
```

## Problemas comuns

- Se o comando `bundle install` falhar por causa de extensões nativas, confirme se os pacotes do passo 1 foram instalados.
- Se o Rails reclamar de asset compilation, rode novamente `yarn install`.
- Se aparecer erro de versão do Ruby, confirme com `rbenv global 2.7.0` e execute `ruby -v`.

## Comandos principais resumidos

```bash
bundle install
yarn install
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails s
```