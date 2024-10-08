# README - Script de Backup MySQL

Este script realiza backups automáticos de bancos de dados MySQL, compacta os arquivos em formato `.zip`, e faz a remoção de backups antigos após um período de retenção. A seguir, estão as instruções para configurar, usar o script, e programá-lo no cron para execução automática.

---

## Pré-requisitos

- **MySQL** instalado e configurado no servidor.
- **Permissões adequadas** no MySQL para o usuário definido no arquivo de configuração (`config.cnf`).
- Ferramentas necessárias: `mysqldump`, `zip`, `grep`.

---

## Arquivos

- **`backup.sh`**: Script principal de backup.
- **`config.cnf`**: Arquivo de configuração com as credenciais de acesso ao MySQL.

---

## Como Usar

### 1. Preparar o ambiente

- Copie o script `backup.sh` para o seu servidor:

  ```bash
  cp backup.sh /caminho/desejado/
  ```

- Edite o arquivo `config.cnf.example` e renomeie-o para `config.cnf`:

  ```bash
  mv config.cnf.example config.cnf
  ```

- No arquivo `config.cnf`, substitua as variáveis `user`, `password` e `host` com as informações do seu banco de dados MySQL:

  ```ini
  [client]
  user = "usuario_bd"
  password = "senha_bd"
  host = "localhost"
  ```

### 2. Configurar o script

Abra o script `backup.sh` e ajuste as variáveis conforme necessário:

- **`CNF_FILE`**: Caminho do arquivo de configuração MySQL (ex.: `./config.cnf`).
- **`BACKUP_DIR`**: Diretório onde os backups serão armazenados (ex.: `/caminho/para/backups`).
- **`RETENTION_TIME`**: Tempo de retenção dos arquivos de backup em minutos. O valor atual corresponde a **90 dias** (60 * 24 * 90).

### 3. Executar o script manualmente

Antes de programar o script no cron, é recomendável testá-lo manualmente para garantir que está funcionando conforme o esperado. Execute o comando:

```bash
bash /caminho/para/backup.sh
```

- **Saída esperada**: O script vai exibir mensagens de progresso para cada etapa do backup, como o início do backup de cada banco, a criação do arquivo `.zip`, e a remoção de backups antigos.

---

## Automatização com o Cron

O cron é uma ferramenta de agendamento de tarefas no Linux. Você pode programar o script para ser executado automaticamente em intervalos regulares.

### 1. Editar o crontab

Para agendar o script, abra o crontab com o comando:

```bash
crontab -e
```
<sub>Dica: Se você inserir `EDITOR=nano` antes do comando crontab, ele irá abrir o arquivo com o Nano caso tenha disponível em seu servidor. Ele é um editor mais robusto e prático de utilizar.</sub>

### 2. Programar o script

Adicione a linha abaixo ao seu arquivo `crontab` para agendar o script de backup. Este exemplo programa o backup para ser executado diariamente às 02:00 da manhã (lembre-se de considerar o fuso horário do seu servidor, caso ele esteja hospedado fora do Brasil):

```bash
0 2 * * * /bin/bash /caminho/para/backup.sh >> /caminho/para/logs/backup.log 2>&1
```

- **`/caminho/para/backup.sh`**: Substitua pelo caminho onde o script `backup.sh` está localizado.
- **`/caminho/para/logs/backup.log`**: Substitua pelo caminho onde deseja armazenar o log do backup.

---

## Explicação do Script

1. **Verificação de Arquivos**: O script verifica se o arquivo de configuração `config.cnf` existe. Se não existir, o processo de backup é interrompido.
   
2. **Criação do Diretório**: O script cria o diretório de backup especificado, se ele não existir.

3. **Listagem de Bancos de Dados**: O script obtém a lista de bancos de dados, excluindo os bancos padrão do MySQL (como `information_schema`, `performance_schema`, etc.).

4. **Backup dos Bancos de Dados**: Para cada banco listado, o script executa o `mysqldump`, gerando um arquivo `.sql` para cada banco.

5. **Compactação**: Todos os arquivos `.sql` são compactados em um único arquivo `.zip`.

6. **Remoção de Backups Antigos**: O script apaga backups antigos com mais de 90 dias (ajustável pela variável `RETENTION_TIME`).

---

## Considerações Finais

- Verifique regularmente o diretório de logs para garantir que o backup está sendo executado sem problemas.
- Certifique-se de que o diretório de backup tem espaço em disco suficiente para armazenar os arquivos gerados.
- Ajuste o tempo de retenção conforme as necessidades do seu sistema.
