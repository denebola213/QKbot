# QKbot
茨城高専の休講情報などを通知するbot  

__Branch: e-souzou__  
e-創造工学の授業のために作成した、web app を追加したブランチ。  

## Requirements
- Docker 18.06+ (Docker running on my server is ver.18.06.0-ce)
- Docker-compose 1.17.1
- used TwitterAPI and DiscordAPI

## Usage
### QKbotのディレクトリに移動  
``` 
cd /this/source/path
```

> **Note:** branch:e-souzou では以下の手順を行って、webapp用のディレクトリを作成する。  
> ```
> cd /this/source/path/app
> mkdir tmp
> mkdir tmp/pids
> mkdir tmp/sockets
> mkdir log
> ``` 
> 終わったあとのディレクトリは以下のようになっている
> ```
> /this/source/path/app
> ├── app.rb
> ├── config.ru
> ├── Dockerfile
> ├── Gemfile
> ├── Gemfile.lock
> ├── info.rb
> ├── log
> ├── tmp
> │   ├── pids
> │   └── sockets
> ├── unicorn.rb
> └── views
>     └── index.haml
> ```

### 設定ファイル .env を作成
`template.env`に必要事項を書いて、  
```
mv template.env .env
```

### 実行
```
docker-compose build
docker-compose pull
docker-compose up
```
complete!
