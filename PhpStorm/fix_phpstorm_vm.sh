#!/bin/bash
set -e

# Находим последнюю установленную версию PhpStorm
VERSION=$(ls -1d "$HOME/Library/Application Support/JetBrains/PhpStorm"* 2>/dev/null | \
          sed -E 's/.*PhpStorm([0-9.]+)$/\1/' | sort -V | tail -n1)

if [ -z "$VERSION" ]; then
  echo "PhpStorm не найден в ~/Library/Application Support/JetBrains/"
  exit 1
fi

echo "➡️  Найдена версия PhpStorm $VERSION"

# Пути
CUSTOM_DIR="$HOME/Library/Application Support/JetBrains/PhpStorm$VERSION"
CUSTOM_FILE="$CUSTOM_DIR/phpstorm.vmoptions"
DEFAULT_FILE="/Applications/PhpStorm.app/Contents/bin/phpstorm.vmoptions"

mkdir -p "$CUSTOM_DIR"

# Если кастомного файла нет — копируем дефолтный
if [ ! -f "$CUSTOM_FILE" ]; then
  echo "Кастомный vmoptions не найден, копирую дефолтный..."
  cp "$DEFAULT_FILE" "$CUSTOM_FILE"
fi

# Делаем бэкап
cp "$CUSTOM_FILE" "$CUSTOM_FILE.bak.$(date +%Y%m%d%H%M%S)"

# Записываем новые параметры
cat > "$CUSTOM_FILE" <<EOF
-Xms2048m
-Xmx8192m
-XX:ReservedCodeCacheSize=1024m
-XX:+UseG1GC
-XX:+UseStringDeduplication
-Dsun.io.useCanonCaches=false
-Djava.net.preferIPv4Stack=true
-XX:+HeapDumpOnOutOfMemoryError
EOF

echo "PhpStorm VM options обновлены в $CUSTOM_FILE"

# Если PhpStorm запущен — убиваем
if pgrep -f "PhpStorm.app" > /dev/null; then
  echo "Останавливаю PhpStorm..."
  osascript -e 'quit app "PhpStorm"'
  sleep 3
fi

# Запускаем снова
echo "Запускаю PhpStorm..."
open -a "PhpStorm"