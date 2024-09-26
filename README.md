# FastAPIアプリケーションのDocker化とAzureデプロイ

## アジェンダ
- [概要](#概要)
- [前提条件](#前提条件)
- [構築手順](#構築手順)

---

## 概要

本ハンズオンでは、以下のステップを通じてFastAPIで構築したシンプルなアプリケーションをDockerコンテナ化し、Azure Container Registry (ACR) にプッシュした後、Azure Container Appsを用いてデプロイする方法を学びます。

**学習内容:**
- FastAPIアプリケーションの作成とローカルでの動作確認
- シングルステージビルドを用いたDockerコンテナの作成
- Dockerイメージのビルドとローカル動作確認
- Azure Container Registry (ACR) の作成と管理者アクセスの有効化
- ACRへのDockerイメージのプッシュ
- Azure Container Appsへのデプロイと動作確認

**今回構成するアーキテクチャ**
![image](https://github.com/user-attachments/assets/92994118-46c1-4780-ab5a-2230ee915a82)

---

## 前提条件

ハンズオンを実施するために以下の環境とツールが必要です。

### 必要なもの
- **Azureアカウント:** [Azureポータル](https://portal.azure.com/)でサインアップまたはサインインしてください。
- **Azure CLI:** 最新バージョンをインストールしてください。インストール方法は[こちら](https://docs.microsoft.com/ja-jp/cli/azure/install-azure-cli)を参照してください。
- **Docker:** Docker Desktopをインストールし、動作確認を行ってください。インストール方法は[こちら](https://docs.docker.com/get-docker/)を参照してください。
- **GitHubアカウント:** ソースコードの管理に使用します。

### ソフトウェアのインストール
- **Git:** Gitをインストールしてください。インストール方法は[こちら](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)を参照してください。
- **Python 3.11 (Option)** またはそれ以上のバージョン

---

## 構築手順

以下の手順に従って、FastAPIアプリケーションをDockerコンテナ化し、Azureにデプロイします。

### Step 1: アプリケーションのセットアップ

1. **サンプルコードの入ったリポジトリをクローンし、プロジェクトに移動します。**
   
   ```bash
   git clone https://github.com/marumaru1019/POC-Container-Handson.git
   cd POC-Container-Handson
   ```

### Step 2: ローカルでの動作確認 (Option)

1. **依存関係のインストール**
   
   ```bash
   pip install -r requirements.txt
   ```

2. **アプリケーションの起動**
   
   ```bash
   uvicorn main:app --reload
   ```

3. **動作確認**
   - ブラウザで [http://127.0.0.1:8000](http://127.0.0.1:8000) にアクセスし、`{"message": "Hello, Container!"}` が表示されることを確認します。
   - Swagger UIを確認するには [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) にアクセスします。


### Step 3: Dockerイメージのビルド

1. **イメージをビルドするコマンド**

   ```bash
   docker build -t <イメージ名>:<タグ(例: v0)> .
   ```

   **例:**

   ```bash
   docker build -t myfastapiapp:v0 .
   ```

2. **イメージの確認**

   ```bash
   docker images
   ```

### Step 4: コンテナのローカル動作確認

1. **コンテナの実行**

   ```bash
   docker run -d -p 80:80 --name <コンテナ名> <イメージ名>:<タグ(例: v0)>
   ```

   **例:**

   ```bash
   docker run -d -p 80:80 --name myfastapiapp_container myfastapiapp:v0
   ```

2. **動作確認**
   - ブラウザで [http://localhost](http://localhost) にアクセスし、`{"message": "Hello, Container!"}` が表示されることを確認します。
   - Swagger UIを確認するには [http://localhost/docs](http://localhost/docs) にアクセスします。

3. **コンテナの停止と削除**

   ```bash
   docker stop <コンテナ名>
   docker rm <コンテナ名>
   ```

   **例:**

   ```bash
   docker stop myfastapiapp_container
   docker rm myfastapiapp_container
   ```

### Step 5: Azure Container Registry (ACR) の作成

1. **Azure CLIを使用してACRを作成**

   ```bash
   # リソースグループの作成
   az group create --name <リソースグループ名> --location <リージョン>
   
   # ACRの作成
   az acr create --resource-group <リソースグループ名> --name <ACR名> --sku Basic
   ```

   **例:**

   ```bash
   az group create --name myResourceGroup --location japaneast
   az acr create --resource-group myResourceGroup --name myACRRegistry --sku Basic
   ```

2. **ACRの管理者アクセスを有効にする**

   ```bash
   az acr update --name <ACR名> --admin-enabled true
   ```

   **例:**

   ```bash
   az acr update --name myACRRegistry --admin-enabled true
   ```

### Step 6: ACRへのログインとイメージのプッシュ

1. **ACRにログイン**

   ```bash
   az acr login --name <ACR名>
   ```

   **例:**

   ```bash
   az acr login --name myACRRegistry
   ```

2. **イメージのタグ付け**

   ```bash
   docker tag <イメージ名>:<タグ(例: v0)> <ACR名>.azurecr.io/<イメージ名>:<タグ(例: v0)>
   ```

   **例:**

   ```bash
   docker tag myfastapiapp:v0 myACRRegistry.azurecr.io/myfastapiapp:v0
   ```

3. **イメージのプッシュ**

   ```bash
   docker push <ACR名>.azurecr.io/<イメージ名>:<タグ(例: v0)>
   ```

   **例:**

   ```bash
   docker push myACRRegistry.azurecr.io/myfastapiapp:v0
   ```

### Step 7: Azure Container Appsでのデプロイ

1. **Azure Container Apps環境の作成**

   ```bash
   az containerapp env create --name <環境名> --resource-group <リソースグループ名> --location <リージョン>
   ```

   **例:**

   ```bash
   az containerapp env create --name myContainerAppEnv --resource-group myResourceGroup --location japaneast
   ```

2. **ACRの認証シークレットの設定**

   ```bash
   az containerapp secret set --name <コンテナアプリ名> --resource-group <リソースグループ名> --secrets <シークレット名>=<ACRパスワード>
   ```

   **例:**

   ```bash
   az containerapp secret set --name myFastAPIApp --resource-group myResourceGroup --secrets arc11223azurecrio-acr11223=<your_acr_password>
   ```

3. **コンテナアプリの作成**

   ```bash
   az containerapp create --name <コンテナアプリ名> --resource-group <リソースグループ名> --environment <環境名> --image <ACR名>.azurecr.io/<イメージ名>:<タグ(例: v0)> --target-port 80 --ingress 'external' --registry-server <ACR名>.azurecr.io --registry-username <ACRユーザー名> --registry-password $(az containerapp secret show --name <コンテナアプリ名> --resource-group <リソースグループ名> --query secrets.<シークレット名> --output tsv)
   ```

   **例:**

   ```bash
   az containerapp create --name myFastAPIApp --resource-group myResourceGroup --environment myContainerAppEnv --image myACRRegistry.azurecr.io/myfastapiapp:v0 --target-port 80 --ingress 'external' --registry-server myACRRegistry.azurecr.io --registry-username myACRRegistry --registry-password $(az containerapp secret show --name myFastAPIApp --resource-group myResourceGroup --query secrets.arc11223azurecrio-acr11223 --output tsv)
   ```

   **注:**
   - `<シークレット名>` は先ほど設定したシークレット名 `arc11223azurecrio-acr11223` と一致させてください。
   - `<ACRユーザー名>` は `az acr credential show --name <ACR名>` コマンドで取得できます。

### Step 8: デプロイ後の確認

1. **デプロイされたアプリケーションのURL確認**

   ```bash
   az containerapp show --name <コンテナアプリ名> --resource-group <リソースグループ名> --query properties.configuration.ingress.fqdn --output tsv
   ```

   **例:**

   ```bash
   az containerapp show --name myFastAPIApp --resource-group myResourceGroup --query properties.configuration.ingress.fqdn --output tsv
   ```

2. **ブラウザでアクセス**
   - 取得したURLにアクセスして、`{"message": "Hello, Container!"}` が表示されることを確認します。

---

## まとめ

本ハンズオンでは、以下の一連の手順を通じて、FastAPIアプリケーションの作成からローカルでの動作確認、Dockerコンテナ化、Azure Container Registry (ACR) へのプッシュ、そしてAzure Container Appsへのデプロイまでを学習しました。

- **FastAPIアプリケーションの作成とローカル動作確認**
- **シングルステージビルドを用いたDockerコンテナの作成**
- **Dockerイメージのビルドとローカル動作確認**
- **Azure Container Registry (ACR) の作成と管理者アクセスの有効化**
- **ACRへのDockerイメージのプッシュ**
- **Azure Container Appsへのデプロイと動作確認**
