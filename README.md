# vqr-manager  
Put files to $HOME/vqr-manager  
# ex.  
sudo apt install unzip  
sudo apt install wget  
wget https://github.com/surugh/vqr-manager/archive/refs/heads/main.zip  
unzip main.zip  
rm -rf vqr-manager # if exist old manager  
mv vqr-manager-main vqr-manager  
rm main.zip  
chmod +x $HOME/vqr-manager/vqr-manager    
$HOME/vqr-manager/./vqr-manager  
# configure  
in telegram-send  
TG_BOT_ID=""  # bot token from @BotFather  
TG_CHAT_ID=""  

in send funds  
AMOUNT=""  
SEND_TO=""  
