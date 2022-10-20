
\\\\\\\\ TRADUZIDO POR @TALKERA ////

Projeto_SSH: t.me/ssh_t_project

\\\\\\\\\\\ CREDITOS A 233BOY //////

### Instalar ou desinstalar
Use o usuário root para digitar o seguinte comando para instalar ou desinstalar
````
bash <(curl -s -L https://raw.githubusercontent.com/TelksBr/v2ray/master/install.sh)
````
** Se o link acima não funcionar, você pode usar o seguinte método **
````
git clone https://github.com/TelksBr/v2ray.git -b master
cd v2ray
chmod +x install.sh
./install.sh local
````

### Características
- Suporta a maioria dos protocolos de transporte V2Ray
- Suporte WebSocket + TLS/HTTP/2
- Suporta portas dinâmicas (WebSocket + TLS, Socks5, exceto HTTP/2)
- Suporte ao bloqueio de anúncios
- Suporte para configurar Shadowsocks
- Suporte para download do arquivo de configuração do cliente (pode baixar sem Xshell)
- O perfil do cliente suporta SOCKS e HTTP
- Suporte para gerar o link do código QR de configuração do V2Ray (aplicável apenas a alguns clientes)
- Suporte para gerar link de informações de configuração do V2Ray
- Suporte para gerar o link do código QR de configuração do Shadowsocks
- Suporte para modificar o protocolo de transmissão V2Ray
- Suporte para modificar a porta V2Ray
- Suporte para modificar portas dinâmicas
- Suporte para modificar o ID do usuário
- Suporte para modificar o nome de domínio TLS
- Suporte para modificar a porta Shadowsocks
- Suporte para modificar a senha do Shadowsocks
- Suporte para modificar o protocolo de criptografia Shadowsocks
- Habilitar otimizações BBR automaticamente (se suportado pelo kernel)
- Instalação opcional integrada BBR (por teddysun.com)
- Instalação opcional integrada Sharp Speed ​​(por moeclub.org)
- Ver o status de execução/ver informações de configuração/iniciar/parar/reiniciar/atualizar/desinstalar/etc…
- Assistente humanizado e instalação limpa e desinstalação completa

Hahaha.. Eu deliberadamente quero escrever o suficiente para 23. Claro, o script definitivamente terá as funções mencionadas acima.

### Gerenciamento rápido
````
v2ray information Ver informações de configuração do V2Ray
v2ray configuration Modifique a configuração do V2Ray
v2ray link Gerar link do arquivo de configuração do V2Ray
v2ray infolink Gerar link de informações de configuração do V2Ray
v2ray qr Gerar link de código QR de configuração do V2Ray
v2ray ss Modificar a configuração do Shadowsocks
v2ray ssinfo Exibir informações de configuração do Shadowsocks
v2ray ssqr gera o link do código QR de configuração do Shadowsocks
v2ray status Veja o status de execução do V2Ray
v2ray Start Iniciar O v2ray
v2ray stop Parar o V2ray
v2ray restarts reinicia o V2Ray
v2ray log Ver log de execução do V2Ray
v2ray update atualizar v2ray
v2ray update.sh atualiza o script de gerenciamento do V2Ray
v2ray uninstall desinstalar v2ray
````

### Caminho do arquivo de configuração
````
Caminho do arquivo de configuração do V2Ray: /etc/v2ray/config.json
Caminho do arquivo de configuração do Caddy: /etc/caddy/Caddyfile
Caminho do arquivo de configuração do script: /etc/v2ray/233blog_v2ray_backup.conf
````

**Aviso, não modifique o arquivo de configuração do script para evitar erros. . **
Se você não tiver necessidades especiais, não modifique o arquivo de configuração do V2Ray
Mas tudo bem, se você realmente quer mexer, se cometer um erro, você desinstala, depois reinstala, depois comete um erro, depois desinstala, depois reinstala, repete até não querer mais jogar fora. .

###WS+TLS/HTTP2
Se você usar esses dois protocolos, usará a integração do Caddy que acompanha o script
De qualquer forma, não é recomendado alterar a configuração do Caddy diretamente: /etc/caddy/Caddyfile
Se você precisar configurar outros sites, coloque o arquivo de configuração do site no diretório /etc/caddy/sites e reinicie o processo do Caddy. A configuração do Caddy gerada pelo script será carregada no diretório /etc/caddy/ todos os arquivos de configuração.
Então, por favor, coloque o arquivo de configuração do seu site no diretório /etc/caddy/sites, não há absolutamente nenhuma necessidade de alterar /etc/caddy/Caddyfile
Lembre-se de reiniciar o processo do Caddy: reinicialização do caddy de serviço

### Plugin do Caddy relacionado
Este script se integra ao Caddy, mas não integra nenhum plugin do Caddy. Se você precisar instalar alguns plugins do Caddy, você pode usar o script de instalação oficial do Caddy para instalá-los com um clique.
O caminho de instalação do Caddy integrado ao meu script é o mesmo que o script de instalação oficial do Caddy. Para que possa ser instalado diretamente sem problemas

Por exemplo, para instalar o Caddy com o plug-in http.filebrowser, execute o seguinte comando

````
curl https://getcaddy.com | bash -s http.filebrowser pessoal
````

Você pode encontrar mais plugins Caddy e comandos de instalação em https://caddyserver.com/download.

### Observação
A porta de escuta SOCKS do arquivo de configuração do cliente V2Ray é 2333, a porta de escuta HTTP é 6666
Pode haver opções ou descrições ligeiramente diferentes para alguns clientes V2Ray, mas, na verdade, as informações de configuração do V2Ray exibidas por este script já são detalhadas o suficiente. Devido aos diferentes clientes, por favor, sente-se.

### Use Cloudflare para retransmitir o tráfego V2Ray
Preocupado com o bloqueio do IP? Ou não quer ser bloqueado por IP? Sim! Basta usar o Cloudflare para retransmitir o tráfego WebSocket do V2Ray! Devido ao uso do trânsito Cloudflare, a parede não sabe qual é o IP por trás dela, você pode jogar feliz~

lembrar
Se você não é um usuário de banda larga móvel, então a velocidade de trânsito usando Cloudflare é relativamente lenta, por causa do problema da linha e não há solução.
aviso aviso aviso
Atualmente, o tutorial é relativamente simples e tutoriais gráficos detalhados devem ser adicionados no futuro.
O WS + TLS da V2Ray não é um mito, não se apresse em correr se você não aprendeu a andar
Cara grande. . . Se você é alguém que nunca esteve em contato com o V2Ray, comece a jogar WS + TLS assim que aparecer
Você realmente não tem medo de lutar?
Você já resolveu um nome de domínio, sabe o que é um registro A e vai modificar o NS? .
Se você não entender, adicione esse conhecimento primeiro e depois olhe para baixo
Se você realmente quer jogar WS + TLS, por favor leia o tutorial com atenção
O tutorial é bem rudimentar. Se o lançamento não der certo, é normal. Volte outro dia.
ou simplesmente desistir

Preparar
Um nome de domínio, é recomendável usar um nome de domínio gratuito
Verifique se o nome de domínio já está funcionando com a Cloudflare.
Você pode visualizar o status do nome de domínio na guia Visão geral da Cloudflare, verifique se ele está ativo, ou seja: Status: Ativo
Como fazer SSH para o IP murado?O Xshell pode definir o proxy nas propriedades, ou você pode usar o iptables para encaminhar dados para a máquina murada em um VPS no exterior sem a parede, e não entrarei em detalhes aqui.

Adicionar resolução de nome de domínio
Adicione uma resolução de nome de domínio de registro A na guia DNS, supondo que seu nome de domínio seja 233blog.com e você queira usar www.233blog.com como o nome de domínio para derrubar o muro
Em seguida, configure-o no DNS, escreva www para Nome e escreva seu IP VPS para o endereço IPv4, certifique-se de acinzentar a nuvem e selecione Adicionar registro para adicionar um registro de resolução.
(Se você adicionou resolução de nome de domínio, certifique-se de deixar a nuvem cinza, ou seja, somente DNS)

OK, se não houver nenhum problema com a operação, continue

Instalar o V2Ray
Se você usou o script de instalação de um clique do V2Ray fornecido por mim e instalou o V2Ray, entre diretamente na configuração do v2ray para modificar o protocolo de transmissão para WebSocket + TLS

Se você não usou o script de instalação de um clique do V2Ray fornecido neste site para instalar o V2Ray
Então comece a usar agora, o melhor script de instalação do V2Ray para garantir sua satisfação
Use o usuário root para digitar o seguinte comando para instalar ou desinstalar
````
bash <(curl -s -L https://raw.githubusercontent.com/TelksBr/v2ray/master/install.sh)
````

Se ele solicitar curl: command not found , é porque seu pintinho não tem o Curl instalado
Como instalar o Curl no sistema ubuntu/debian: apt-get update -y && apt-get install curl -y
Método Curl de instalação do sistema Centos: yum update -y && yum install curl -y
Depois de instalar o curl, você pode instalar o script

Em seguida, escolha instalar, escolha WebSocket + TLS para protocolo de transmissão (ou seja, escolha 4), a porta V2Ray é opcional, não 80 e 443, insira seu nome de domínio, resolução de nome de domínio Y, TLS configurado automaticamente também é Y, outros são padrão, todo o caminho de volta. Aguarde a conclusão da instalação
Se o seu nome de domínio não for resolvido corretamente, a instalação falhará. Para obter a resolução, consulte Adicionar resolução de nome de domínio acima.

Após a conclusão da instalação, as informações de configuração do V2Ray serão exibidas, e ele perguntará se deseja gerar um código QR, etc., não se preocupe com isso, basta pressionar Enter

Em seguida, insira o status v2ray para verificar o status de execução, verifique se o V2Ray e o Caddy estão em execução

Se não houver problema, continue

Configure o Crypto e habilite a retransmissão
Certifique-se de que a guia Crypto da Cloudflare tenha SSL em Full
E certifique-se de que a guia SSL mostra as palavras Universal SSL Status Active Certificate, se sua guia SSL não mostrar isso, não se preocupe, basta solicitar um certificado, isso pode ser feito em 24 horas.

Em seguida, na guia DNS, ative o ícone da nuvem que estava acinzentado e acenda-o, certifique-se de acendê-lo, acendê-lo, acendê-lo

O ícone da nuvem deve ser laranja, ou seja, DNS e proxy HTTP (CDN)

Informações de configuração do V2Ray
Muito bom, agora configure o cliente para usar
Digite as informações do v2ray para visualizar a configuração do V2Ray. Se você usa alguns clientes V2Ray, pode configurá-lo e usá-lo de acordo com as informações de configuração fornecidas. teste agora
