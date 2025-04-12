#!/bin/bash

# === 設定 ===
# 想定されるデスクトップのパス (必要に応じて追加・変更してください)
DESKTOP_PATHS=( "$HOME/Desktop" "$HOME/デスクトップ" )
APPIMAGE_NAME="Cursor.AppImage" # 探すAppImageファイル名
CONFIG_DIR="$HOME/.config/Cursor" # 削除対象の設定ディレクトリ
DATA_DIR="$HOME/.local/share/Cursor" # 削除対象のデータディレクトリ
CACHE_DIR="$HOME/.cache/Cursor" # 削除対象のキャッシュディレクトリ
# LEGACY_CONFIG_DIR="$HOME/.cursor" # 古い形式の設定ディレクトリ (必要ならコメント解除)

APPIMAGE_FOUND_PATH=""

# === Ctrl+C (SIGINT) を捕捉して終了する設定 (NEW) ===
# Ctrl+Cが押された場合にメッセージを表示して終了する
trap 'echo -e "\nCtrl+C により処理が中断されました。" >&2; exit 1;' SIGINT

# === デスクトップ上の AppImage ファイルを探す ===
echo "デスクトップで $APPIMAGE_NAME を検索しています..."
for D_PATH in "${DESKTOP_PATHS[@]}"; do
  if [ -f "$D_PATH/$APPIMAGE_NAME" ]; then
    APPIMAGE_FOUND_PATH="$D_PATH/$APPIMAGE_NAME"
    echo "発見しました: $APPIMAGE_FOUND_PATH"
    break # 見つかったらループを抜ける
  fi
done

# === AppImage が見つからない場合は終了 ===
if [ -z "$APPIMAGE_FOUND_PATH" ]; then
  echo "$APPIMAGE_NAME がデスクトップに見つかりませんでした。"
  echo "アンインストール処理を中止します。"
  exit 1
fi

# === 削除対象の警告表示 (確認の前に行う) ===
echo "-------------------------------------------------------------"
echo "警告: 以下のファイルとディレクトリが完全に削除されます！"
echo "元に戻すことはできません！"
echo "-------------------------------------------------------------"
echo "  - AppImage ファイル: $APPIMAGE_FOUND_PATH"
[ -d "$CONFIG_DIR" ] && echo "  - 設定ディレクトリ: $CONFIG_DIR (とその中身全て)"
[ -d "$DATA_DIR" ] && echo "  - データディレクトリ: $DATA_DIR (とその中身全て)"
[ -d "$CACHE_DIR" ] && echo "  - キャッシュディレクトリ: $CACHE_DIR (とその中身全て)"
# [ -d "$LEGACY_CONFIG_DIR" ] && echo "  - 旧設定ディレクトリ: $LEGACY_CONFIG_DIR (とその中身全て)" # 必要ならコメント解除
echo "-------------------------------------------------------------"

# === 3回の確認プロセス (NEW) ===
for i in 1 2 3; do
    # 確認回数に応じてメッセージを変える
    case $i in
        1) prompt_suffix="【1回目/3回】";;
        2) prompt_suffix="【2回目/3回】";;
        3) prompt_suffix="【最終確認 3回目/3回】";;
    esac

    # 確認を求める
    read -p "本当に削除を実行しますか？ $prompt_suffix (y/N): " confirmation

    # y または Y 以外が入力されたらキャンセルして終了
    if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
        echo "ユーザーにより処理がキャンセルされました (確認 $i/3)。"
        exit 0
    fi
done

# 3回 'y' が入力された場合のみ、ここに来る
echo # 改行
echo "3回の確認が完了しました。削除処理を開始します..."

# === 削除処理の開始 ===
# (削除ロジックは前回と同じ)

# AppImage ファイルの削除
echo "- $APPIMAGE_FOUND_PATH を削除中..."
rm -f "$APPIMAGE_FOUND_PATH"
if [ $? -eq 0 ]; then echo "  -> 成功"; else echo "  -> 失敗"; fi

# 設定ディレクトリの削除
if [ -d "$CONFIG_DIR" ]; then
  echo "- $CONFIG_DIR を削除中..."
  rm -rf "$CONFIG_DIR"
  if [ $? -eq 0 ]; then echo "  -> 成功"; else echo "  -> 失敗"; fi
else
  echo "- $CONFIG_DIR は存在しませんでした。"
fi

# データディレクトリの削除
if [ -d "$DATA_DIR" ]; then
  echo "- $DATA_DIR を削除中..."
  rm -rf "$DATA_DIR"
  if [ $? -eq 0 ]; then echo "  -> 成功"; else echo "  -> 失敗"; fi
else
  echo "- $DATA_DIR は存在しませんでした。"
fi

# キャッシュディレクトリの削除
if [ -d "$CACHE_DIR" ]; then
  echo "- $CACHE_DIR を削除中..."
  rm -rf "$CACHE_DIR"
  if [ $? -eq 0 ]; then echo "  -> 成功"; else echo "  -> 失敗"; fi
else
  echo "- $CACHE_DIR は存在しませんでした。"
fi

# # 古い形式の設定ディレクトリの削除 (必要ならコメント解除)
# if [ -d "$LEGACY_CONFIG_DIR" ]; then
#   # ... (削除ロジック) ...
# fi

echo "-------------------------------------------------------------"
echo "Cursor のアンインストール処理が完了しました。"
echo "必要に応じて、ファイルが削除されたか確認してください。"
echo "-------------------------------------------------------------"

exit 0
