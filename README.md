# TensorFlow-Jetson-Docker
TensorFlowのJetson用Dockerイメージを作成する．

## インストール
```bash
#!/bin/bash
git clone https://github.com/shikishima-TasakiLab/tensorflow-jetson-docker.git Tensorflow-Jetson
```

## 使い方

### Dockerイメージの作成

次のコマンドでDockerイメージをビルドする．
```bash
#!/bin/bash
./Tensorflow-Jetson/docker/build-docker.sh
```
|オプション   |パラメータ   |説明                                      |既定値    |例                                         |
|-------------|-------------|------------------------------------------|----------|-------------------------------------------|
|`-h`, `--help`   |なし         |このヘルプを表示                          |なし      |`-h`|
|`-v`, `--version`|VERSION      |TensorFlowのバージョンを指定する          |`2.0`       |`-v 1.15`|
|`-c`, `--opencv` |{VERSION|OFF}|OpenCVのバージョンを指定する．インストールしない場合は"off"|`4.3.0`|`-c 3.4.1` , `-c off`|

### Dockerコンテナの起動

1. 次のコマンドでDockerコンテナを起動する．networkディレクトリがマウントされる．
    ```bash
    #!/bin/bash
    ./Tensorflow-Jetson/docker/run-docker.sh
    ```
    |オプション   |パラメータ|説明                                      |既定値    |例                                         |
    |-------------|----------|------------------------------------------|----------|-------------------------------------------|
    |`-h`, `--help`   |なし      |このヘルプを表示                          |なし      |`-h`|
    |`-v`, `--version`|VERSION   |TensorFlowのバージョンを指定する          |`2.0`       |`-v 1.15`|
    |`-n`, `--name`   |NAME      |コンテナの名前を指定                      |`tensorflow`|`-n my-net`|
    |`-e`, `--env`    |ENV=VALUE |コンテナの環境変数を指定する（複数指定可）|なし      |`-e LD_LIBRARY_PATH=/usr/local/lib`|
    |`-c`, `--command`|CMD       |コンテナ起動時に実行するコマンドを指定    |なし      |`-c python3` , `-c "python3 ~/network/main.py"` |

2. 起動中のコンテナで複数のターミナルを使用する際は，次のコマンドを別のターミナルで実行する．

    ```bash
    #!/bin/bash
    ./Tensorflow-Jetson/docker/exec-docker.sh
    ```
    |オプション|パラメータ|説明                |既定値    |例             |
    |----------|----------|--------------------|----------|---------------|
    |`-h`, `--help`|なし      |このヘルプを表示    |なし  |`-h`             |
    |`-i`, `--id`  |ID        |コンテナのIDを指定  |なし  |`-i 4f8eb7aeded7`|
    |`-n`, `--name`|NAME      |コンテナの名前を指定|なし  |`-n tensorflow`  |
