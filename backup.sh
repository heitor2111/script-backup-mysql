#!/bin/bash

# Script de backup de bancos de dados MySQL

# Configurações
CNF_FILE="./config.cnf"                                     # Arquivo de configuração do MySQL
BACKUP_DIR="/caminho/para/backups"                          # Pasta para salvar os backups
DATE=$(TZ="America/Sao_Paulo" date +"%Y-%m-%d_%H-%M-%S")    # Formato da data para nomear os arquivos
ZIP_FILE="$BACKUP_DIR/backup_$DATE.zip"                     # Nome do .zip final
RETENTION_TIME=$((60 * 24 * 90))                            # Tempo de retenção dos arquivos em minutos

# Verifica se o arquivo de configuração existe
if [ ! -f "$CNF_FILE" ]; then
    echo "Arquivo de configuração não encontrado: $CNF_FILE"
    exit 1
fi

# Cria a pasta, caso não exista
mkdir -p "$BACKUP_DIR"

# Obtém a lista com todos os bancos de dados, excluindo os bancos padrão do MySQL
databases=$(mysql --defaults-extra-file=$CNF_FILE -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

# Verifica se existem bancos de dados para backup
if [ -z "$databases" ]; then
    echo "Nenhum banco de dados encontrado para backup."
    exit 1
fi

# Executa um loop em cada banco
for db in $databases; do
    echo "Iniciando backup: $db"

    # Define o nome do arquivo
    BACKUP_FILE="$BACKUP_DIR/backup_${db}_${DATE}.sql"

    # Realiza o backup
    mysqldump --defaults-extra-file=$CNF_FILE $db > $BACKUP_FILE

    # Verifica se o backup foi bem sucedido
    if [ $? -eq 0 ]; then
        echo "Backup do banco de dados '$db' concluído com sucesso."
    else
        echo "Erro ao realizar o backup do banco de dados '$db'."
    fi
done

# Verifica se existem arquivos .sql para compactar
if compgen -G "$BACKUP_DIR/*.sql" > /dev/null; then
    # Compacta todos os arquivos .sql em um único .zip
    echo "Compactando backups em $ZIP_FILE"
    zip -j "$ZIP_FILE" "$BACKUP_DIR"/*.sql

    # Verifica se a compactação foi bem sucedida
    if [ $? -eq 0 ]; then
        echo "Compactação dos backups concluída com sucesso."

        # Remove os arquivos .sql originais após compactação
        rm "$BACKUP_DIR"/*.sql
    else
        echo "Erro ao compactar os arquivos de backup."
        exit 1
    fi
else
    echo "Nenhum arquivo .sql encontrado para compactar."
fi

# Exclui backups antigos (mais de 30 dias)
find "$BACKUP_DIR" -name "backup_*.zip" -mmin +"$RETENTION_TIME" -exec rm {} \;

# Verifica se a remoção foi bem sucedida
if [ $? -eq 0 ]; then
    echo "Arquivos antigos removidos com sucesso."
else
    echo "Erro ao remover arquivos antigos."
fi

echo "Processo de backup completo."