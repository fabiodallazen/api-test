# Refactoring de relacionamento

> A Madonna resolveu lançar um album em parceria com a Shakira! E agora?!

Nosso PO jamais iria esperar que um album pudesse ter mais de um artista. Transforme a relacão 1 para N entre Player e Album em uma relação N para N. Precisamos de testes senão o chato do agilista vai brigar conosco!

## REQUIREMENTS

*   Ruby 2.6.0
*   Rails 5.2.0
*   shoulda 3.5+
*   shoulda-matchers 2.0+
*   rails-controller-testing 1.0.4

## INSTALL

Install Bundler
```
$ gem install bundler
```

Install Gems
```
$ bundle install
```

Create database
```
$ rails db:create
```

Run migrations
```
$ rails db:migrate
```
