#!/bin/bash
set -e

# Находим самую свежую папку PhpStorm в Library
CONFIG_DIR=$(ls -d ~/Library/Application\ Support/JetBrains/PhpStorm* | sort -V | tail -n 1)
VMOPTIONS="$CONFIG_DIR/phpstorm.vmoptions"

# Извлекаем версию из имени папки
VERSION=$(basename "$CONFIG_DIR" | sed -E 's/PhpStorm([0-9.]+)/\1/')

echo "Найдена PhpStorm версии: $VERSION"
echo "Конфиг директория: $CONFIG_DIR"

# Делаем бэкап, если файл уже есть
if [ -f "$VMOPTIONS" ]; then
    BACKUP_FILE="$VMOPTIONS.bak_$(date +%Y%m%d%H%M%S)"
    cp "$VMOPTIONS" "$BACKUP_FILE"
    echo "Бэкап создан: $BACKUP_FILE"
fi

# Записываем оптимизированные параметры
cat > "$VMOPTIONS" <<EOF
# Размеры памяти
-Xms1024m
-Xmx8192m
-XX:ReservedCodeCacheSize=1024m

# GC (сборщик мусора)
-XX:+UseG1GC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:+HeapDumpOnOutOfMemoryError

# Оптимизация рендеринга на MacOS
-Dsun.java2d.metal=true
-Dsun.java2d.uiScale.enabled=true

# Ускорение индексации
-Didea.caches.indexerThreadsCount=6

# Стабильность и графика
-Dapple.awt.application.appearance=system
EOF

echo "Новый phpstorm.vmoptions создан"
echo "Перезапусти PhpStorm $VERSION, чтобы изменения вступили в силу."