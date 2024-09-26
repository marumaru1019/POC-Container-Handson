# ベースイメージ
FROM python:3.11-slim

# 作業ディレクトリの設定
WORKDIR /app

# 依存関係のインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションのコピー
COPY . .

# ポートの公開
EXPOSE 80

# コンテナ起動時のコマンド
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
