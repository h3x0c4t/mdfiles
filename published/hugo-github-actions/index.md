---
title: Автоматизация Hugo с GitHub Actions
slug: hugo-github-actions
description: В этой статье будем автоматизировать сборку проекта Hugo с помощью GitHub Actions, а также развернем его на GitHub Pages.
date: 2023-01-07
image: cover.png
categories: 
    - Автоматизация
tags: 
    - hugo
    - github actions
---

## До автоматизации

Создаем новый проект: `hugo new <название>`

На GitHub создаем репозиторий с названием `<username>.github.io`

> Для того, чтобы дальше все проходило без ошибок, убедитесь что у настроены SSH ключи на GitHub. Как это сделать описано [здесь](https://google.com)

Далее в папке с проектом выполняем команды:

```bash
git init
git add .
git commit -m "First commit"
git branch -M main
git remote add origin <SSH ссылка на ваш репозиторий>
git push -u origin main
```

После этого в вашем репозитории должен появиться проект.

![Репозиторий](images/1673099067534.png)  

## Автоматизация

Для автоматизации создадим файл `.github/workflows/gh-pages.yml` с содержимым:

```yaml
name: GitHub Pages

on:
  push:
    branches:
      - main # Ветка, при пуше в которую будет запускаться деплой
  pull_request:

jobs:
  deploy:
    runs-on: ubuntu-22.04
    permissions:
      contents: write
    concurrency:
      group: ${{ github.workflow }}-${{ github.ref }}
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
          fetch-depth: 0

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: "0.109.0" # Версия Hugo
          extended: true # Если вам нужна extended версия Hugo

      - name: Build
        run: hugo --minify

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        # Если вы используете другую ветку, то измените
        # `main` на вашу ветку в `refs/heads/main` ниже.
        if: ${{ github.ref == 'refs/heads/main' }}
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

Теперь, при каждом коммите в ветку `main` будет запускаться автоматизация, которая соберет проект и запушит его в ветку `gh-pages`.

Запушим новый файл в репозиторий:

```bash
git add .
git commit -m "Add GitHub Actions"
git push
```

После этого, в разделе `Actions` должен появиться новый воркфлоу, а в ветке `gh-pages` должен появиться собранный проект.

![workflows](images/1673098971610.png)  

Теперь, нужно перейти в настройки репозитория и в разделе `Pages` выбрать ветку `gh-pages` и папку `/ (root)`.

![gh-pages settings](images/1673098984772.png)  

После сохранения с айт будет доступен по адресу `<username>.github.io`.

## Дополнительно

### Добавление своего домена

Для того, чтобы добавить свой домен, нужно создать файл `CNAME` в папке `static` с содержимым:

```txt
<your-domain>
```

Пушим изменения в репозиторий:

```bash
git add .
git commit -m "Add CNAME"
git push
```

Затем, нужно добавить следующие A записи в DNS:

```txt
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

Также, нужно добавить следующие CNAME записи в DNS:

```txt
<username>.github.io
```

Через некоторое время, сайт будет доступен по вашему домену.

Чтобы принудительного включения HTTPS, ставим галочку `Enforce HTTPS` в настройках репозитория.

![HTTPS](images/1673099036763.png)  

### Добавление сабдомена

Если же вы хотите чтобы сайт был доступен по сабдомену, то также нужно создаем файл `CNAME` в папке `static` с содержимым:

```txt
<subdomain>.<your-domain>
```

Пушим изменения в репозиторий:

```bash
git add .
git commit -m "Add CNAME"
git push
```

Затем, в панели управления доменом добавляем CNAME запись в DNS:

```txt
<username>.github.io
```

Через некоторое время, сайт будет доступен по сабдомену.
